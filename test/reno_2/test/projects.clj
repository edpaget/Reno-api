(ns reno-2.test.projects
  (:use clojure.test
        ring.mock.request
        reno-2.projects)
  (:use [monger.core :as mongo]))

(mongo/connect!)
(m/set-db! (m/get-db "reno-test"))

(deftest projects-routes-test
  (testing "index - /"
    (let [response (projects-routes (request :get "/"))]
      (is (= (:status response) 200) "Returns 200 OK")))
  (testing "create - /"
    (let [response (projects-routes (request :post "/"))]
      (is (= (:status response) 201) "Returns 201 Created")))
  (testing "show - /:id"
    (let [response (projects-routes (request :get "/1"))]
      (is (= (:status response) 200) "Returns 200 OK")))
  (testing "update - /:id"
    (let [response (projects-routes (request :put "/1"))]
      (is (= (:status response) 200) "Returns 200 OK")))
  (testing "delete - /:id"
    (let [response (projects-routes (request :delete "/1"))]
      (is (= (:status response) 204) "Returns 204 No Content"))))

