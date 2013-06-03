(ns reno-2.users
  (:use compojure.core
        reno-2.util
        clojurewerkz.scrypt.core
        monger.operators
        [monger.collection :only [remove-by-id update-by-id ensure-index 
                                  insert-and-return find-map-by-id 
                                  find-one-as-map]]
        [monger.conversion :only [to-object-id]])
  (:require monger.joda-time
            monger.json)
  (:import [org.bson.types ObjectId]
           [java.security MessageDigest]))

(defn- sha256
  "Generates SHA-256 hash of the given inputs"
  [& inputs]
  (let [md (MessageDigest/getInstance "SHA-256")
        input (apply str inputs)]
    (. md update (.getBytes input))
    (let [digest (.digest md)]
      (apply str (map #(format "%02x" (bit-and % 0xff)) digest)))))

(defn by-token
  [token]
  (ensure-index "users" (array-map :token 1))
  (find-one-as-map "users" {:token token}))

(defn by-id
  [id]
  (find-map-by-id "users" (to-object-id id)))

(defn by-auth
  [{:keys [email pass]}]
  (let [user (find-one "users" {:email email})]
    (when (verify pass (:pass user))
      user)))

(defn create!
  [{:keys [email pass]}]
  (ensure-index "users" (array-map :email 1) {:unique true})
  (let [user-record {:_id (ObjectId.)
                     :pass (encrypt pass 16384 8 1)
                     :email email
                     :project-ids []
                     :token (sha256 email (System/currentTimeMillis))}]
    (insert-and-return "users" user-record)))

(defn update-pass!
  [id user {:keys [old-pass new-pass]}]
  (when (and (= id (.toString (:_id user))))
    (verify old-pass (:pass user))
    (do (update-by-id "users" (to-object-id id) 
                      (merge user {:pass (encrypt new-pass 16384 8 1)
                                   :token (sha256 (:email user) 
                                                  (System/currentTimeMillis))}))
        (by-id id))))

(defn update-projects!
  [id & project-ids]
  (doseq [project-id project-ids] 
    (update-by-id "users" (to-object-id id) 
                  {$addToSet {:project-ids [project-id]}})))

(defn delete!
  [id user]
  (when (= id (.toString (:_id user)))
    (remove-by-id "users" (to-object-id id))))

(defn- strip-passwords
  [handler]
  (fn [req]
    (let [response (handler req)]
      (if-let [users (:users (:body response))]
        (update-in response [:body] assoc :users 
                   (into [] (map #(dissoc % :pass) users)))
        response))))

(defroutes raw-routes 
  (GET "/" [user] 
       (resp-ok {:users [user]}))
  (POST "/" {params :params} 
        (resp-created {:users [(create! params)]}))
  (GET "/:id" [id :as r] 
       (resp-ok {:users [(by-id id)]}))
  (PUT "/:id" [id user & pass] 
       (resp-ok {:users [(update-pass! id user pass)]}))
  (DELETE "/:id" [id user] (if-not (nil? (delete! id user))
                             resp-no-content
                             resp-forbidden)))

(def users-routes
  (strip-passwords raw-routes))
