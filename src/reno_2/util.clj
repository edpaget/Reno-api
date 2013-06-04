(ns reno-2.util
  (:use [clj-time.core :only [now]]
        [ring.util.response :only [content-type charset response status]]))

(defn- resp
  [body]
  (partial status (-> (response body)
                      (content-type "application/json")
                      (charset "utf-8"))))

(defn resp-ok 
  "Returns a Ring Response with status 200 OK, 
  content-type application/json, and charset utf-8"
  [body]
  ((resp body) 200))

(defn resp-created
  "Returns a Ring Resposne with status 201 Created, 
  content-type application/json, and charset utf-8"
  [body]
  ((resp body) 201))

(def resp-no-content 
  "A Ring Response with status 204 No-Content, 
  content-type application/json, and charset utf-8" 
  ((resp "") 204))

(def resp-forbidden
  "A ring Response with status 403 Forbidden,
  content-type application/json, and charset utf-8"
  ((resp "") 403))

(defn timestamp
  "Adds updated-at and created-at fields to a map."
  [m]
  (merge {:created-at (now)} m {:updated-at (now)}))
