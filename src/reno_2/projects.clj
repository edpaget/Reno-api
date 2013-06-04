(ns reno-2.projects
  (:use compojure.core
        reno-2.util
        monger.operators
        [clj-time.core :only [now]]
        [monger.conversion :only [to-object-id]]
        [monger.collection :only [insert-and-return find-map-by-id find-maps
                                  update-by-id remove-by-id update]]
        [reno-2.users :only [update-projects!]])
  (:require monger.joda-time
            monger.json)
  (:import [org.bson.types ObjectId]))

(defn- project-authed
  [id user]
  (some #{(to-object-id id)} (:project-ids user)))

(defmacro if-project-authed? [id user body]
  `(if (project-authed ~id ~user)
     ~body
     resp-forbidden))

(defn by-id
  [id]
  (find-map-by-id "projects" (to-object-id id)))

(defn update!
  [id user {:keys [name type commands snapshots build-ids]}]
  (let [project-updated {:_id (to-object-id id)
                         :name name
                         :type type
                         :commands commands
                         :snapshots snapshots
                         :build-ids build-ids}]
    (update-by-id "projects" (to-object-id id) (timestamp project-updated))))

(defn create!
  "Stores a new project in Mongo"
  [user {:keys [name type commands]}]
  (let [project-record {:_id (ObjectId.)
                        :name name
                        :type type
                        :snapshots []
                        :build-ids []
                        :commands commands}]
    (update-projects! (:_id user) (:_id project-record))
    (insert-and-return "projects" (timestamp project-record))))

(defn remove!
  [id]
  (remove-by-id "project" (to-object-id id))  
  resp-no-content)

(defn user-projects
  [{:keys [project-ids]}]
  (let [project-ids (map to-object-id project-ids)] 
    (find-maps "projects" {:_id {$in project-ids}})))

(defn snapshots
  [id]
  (:snapshots (by-id id)))

(defn active-snapshot
  [id]
  (first (filter #(= (:status %) "active") (snapshots id))))

(defn get-snapshot
  [id snap-id]
  (first (filter #(= (:_id %) (to-object-id snap-id)) (snapshots id))))

(defn create-snapshot!
  [id snapshot]
  (let [snapshot (merge snapshot {:_id (ObjectId.)})]
    (update-by-id "projects" (to-object-id id) 
                  {:snapshots {$addToSet (timestamp snapshot)}})))

(defn update-snapshot-status!
  [id snap-id status]
  (update "projects" 
          {:_id (to-object-id id) :snapshots._id {:_id (to-object-id snap-id)}} 
          {$set {:snapshots.$.status status}
                {:snapshots.$.updated-at (now)}})
  (get-snapshot id snap-id))

(defn remove-snapshot!
  [id snap-id]
  (update-by-id "projects" (to-object-id id) {$pull {:snapshots._id {:_id (to-object-id snap-id)}}})
  resp-no-content)

(defroutes projects-routes
  (GET "/" [user] (resp-ok {:projects (user-projects user)}))
  (POST "/" [user & project] 
        (resp-created {:projects [(create! user project)]}))
  (GET "/:id" [id user] 
       (if-project-authed? id user (resp-ok {:projects [(by-id id)]})))
  (PUT "/:id" [id user & project] 
       (if-project-authed? id user (resp-ok {:projects [(update! id user project)]})))
  (DELETE "/:id" [id user] 
          (if-project-authed? id user (remove! id)))
  (GET "/:id/snapshots/" [id user]
       (if-project-authed? id user (resp-ok {:snapshots (snapshots id)})))
  (POST "/:id/snapshots/" [id user & snapshot]
        (if-project-authed? id user (resp-created {:snapshots [(create-snapshot! id snapshot)]})))
  (GET "/:id/snapshots/:snap-id" [id snap-id user] 
       (if-project-authed? id user (resp-ok {:snapshots [(get-snapshot id snap-id)]})))
  (PATCH "/:id/snapshots/:snap-id" [id snap-id user status]
         (if-project-authed? id user (resp-ok {:snapshots [(update-snapshot-status! id snap-id status)]})))
  (DELETE "/:id/snapshots/:snap-id" [id snap-id user]
          (if-project-authed? id user (remove-snapshot! id snap-id))))
