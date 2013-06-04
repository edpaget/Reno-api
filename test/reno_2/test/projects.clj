(ns reno-2.test.projects
  (:use clojure.test
        ring.mock.request
        reno-2.projects
        [reno-2.test.users :only [request-with-params]])
  (:require [monger.core :as mongo]
            [reno-2.users :as user]
            [monger.collection :as mc]))

(mongo/connect!)
(mongo/set-db! (mongo/get-db "reno-test"))
(mc/drop "users")
(mc/drop "projects")

(deftest projects-routes-test
  (let [test-user (user/create! {:email "test-projects@example.com" 
                                 :pass "test-pass"})
        test-project (create! test-user 
                              {:name "Test" :type "brunch" :commands []})
        test-user (user/by-id (:_id test-user))
        test-project-route (str "/" (:_id test-project))] 
    (testing "index - /"
      (let [response (projects-routes 
                       (request-with-params :get "/" {:user test-user}))]
        (is (= (:status response) 200) "Returns 200 OK")))
    (testing "create - /"
      (let [response (projects-routes 
                       (request-with-params :post "/" {:user test-user
                                                       :name "Test2"
                                                       :type "hem"
                                                       :commands []}))]
        (is (= (:status response) 201) "Returns 201 Created")))
    (testing "show - /:id"
      (let [response (projects-routes 
                       (request-with-params :get test-project-route
                                            {:user test-user}))]
        (is (= (:status response) 200) "Returns 200 OK")))
    (testing "update - /:id"
      (let [response (projects-routes 
                       (request-with-params :put test-project-route
                                            {:user test-user
                                             :status "active"}))]
        (is (= (:status response) 200) "Returns 200 OK")))
    (testing "delete - /:id"
      (let [response (projects-routes 
                       (request-with-params :delete test-project-route
                                            {:user test-user}))]
        (is (= (:status response) 204) "Returns 204 No Content")))))
