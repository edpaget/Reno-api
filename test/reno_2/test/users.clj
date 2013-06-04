(ns reno-2.test.users
  (:use clojure.test
        ring.mock.request
        reno-2.users)
  (:require [monger.core :as mongo]
            [monger.collection :as mc]))

(mongo/connect!)
(mongo/set-db! (mongo/get-db "reno-test"))
(mc/drop "users")  

(defn request-with-params 
  [method url params]
  (merge (request method url) {:params params}))

(deftest users-routes-test
  (let [extant-user (create! {:pass "test-pass"
                              :email "first@example.com"}) 
        extant-user-route (str "/" (:_id extant-user))
        user {:pass "test-pass"
              :email "test@example.com"}]

    (testing "index - /"
      (let [response (users-routes 
                       (request-with-params :get "/" {:user extant-user}))]
        (is (= (:status response) 200) "Returns 200 OK")))

    (testing "create - /"
      (let [response (users-routes (request-with-params :post "/" user))]
        (is (= (:status response) 201) "Returns 201 Created")
        (is (= (-> (:body response) :users first :email)
               "test@example.com") "It should return the created user")
        (is (nil? (-> response :body :users first :pass)) 
            "It does not return the password")))

    (testing "show - /:id"
      (let [response (users-routes (request-with-params :get extant-user-route
                                                        {:user extant-user}))]
        (is (= (:status response) 200) "Returns 200 OK")
        (is (= "first@example.com" (-> response :body :users first :email)))))

    (testing "update - /:id"
      (let [response (users-routes (request-with-params :put extant-user-route 
                                                        {:user extant-user 
                                                         :new-pass "test" 
                                                         :old-pass "test-pass"}))]
        (is (= (:status response) 200) "Returns 200 OK")
        (is (= "first@example.com" (-> response :body :users first :email)))))
    (testing "delete - /:id"
      (let [response (users-routes (request-with-params :delete extant-user-route
                                                        {:user extant-user}))]
        (is (= (:status response) 204) "Returns 204 No Content")))))

(deftest create!-test
  (let [user {:pass "test-pass"
              :email "test2@example.com"}] 
    (testing "creating a new user"
      (let [user (create! user)] 
        (is (= "test2@example.com" (:email user)) 
            "It should create a user with the given attributes")
        (is (not (nil? (:token user)))
            "It should have an api token")))))
