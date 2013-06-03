(ns reno-2.handler
  (:use compojure.core)
  (:require [compojure.handler :as handler]
            [compojure.route :as route]))

(defroutes app-routes
  (GET "/" [] "Hello Ed")
  (route/resources "/")
  (route/not-found "Not Found"))

(def app app-routes)
