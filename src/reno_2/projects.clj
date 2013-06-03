(ns reno-2.projects
  (:use compojure.core
        reno-2.util
        monger.operators
        [monger.conversion :only [to-object-id]]
        [monger.collection :only [insert-and-return find-map-by-id find-maps
                                  update-by-id remove-by-id]]
        [reno-2.users :only [update-projects!]])
  (:require monger.joda-time
            monger.json)
  (:import [org.bson.types ObjectId]))

(defn by-id
  [id]
  (find-map-by-id "projects" (to-object-id id)))

(defn update!
  [id user {:keys [name type commands deploys]}]
  (let [project-updated {:_id (to-object-id id)
                         :name name
                         :type type
                         :commands commands
                         :deploys deploys}]
    (update-by-id "projects" (to-object-id id) project-updated)))

(defn create!
  "Stores a new project in Mongo"
  [user {:keys [name type commands]}]
  (let [project-record {:_id (ObjectId.)
                        :name name
                        :type type
                        :deploys []
                        :commands commands}]
    (update-projects! (:_id user) (:_id project-record))
    (insert-and-return "projects" project-record)))

(defn user-projects
  [{:keys [project-ids]}]
  (let [project-ids (map to-object-id project-ids)] 
    (find-maps "projects" {:_id {$in project-ids}})))

(def project-authed
  [id user]
  (some #{id} (:project-ids user)))

(defroutes projects-routes
  (GET "/" [user] (resp-ok {:projects (user-projects user)}))
  (POST "/" [user & project] 
        (resp-created {:projects [(create! user project)]}))
  (GET "/:id" [id user] 
       (if (project-authed id user) 
         (resp-ok {:projects [(by-id id)]})
         (resp-forbidden)))
  (PUT "/:id" [id user & project] 
       (if (project-authed id user)
         (resp-ok {:projects [(update! id user project)]})
         (resp-forbidden)))
  (DELETE "/:id" [id] 
          (if (project-authed id user)
            (do (remove-by-id "project" (to-object-id id))
                resp-no-content)
            resp-forbidden)))
