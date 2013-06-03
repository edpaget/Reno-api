(ns reno-2.test.util
  (:use clojure.test
        reno-2.util))

(deftest test-responses
  (testing "resp-ok"
    (let [response (resp-ok [1 2 3 4 5])]
      (is (= (:status response) 200) "It should have a status of 200")
      (is (= ((:headers response) "Content-Type") 
             "application/json; charset=utf-8") 
          "It should have a json content-type")))
  (testing "resp-craeted"
    (is (= (:status (resp-created [1 2 3 4 5])) 201) 
        "It should have a status of 200"))
  (testing "resp-no-content"
    (is (= (:status resp-no-content) 204) 
        "It should have a status of 204"))
  (testing "resp-forbidden"
    (is (= (:status resp-forbidden) 403)
        "It should have a status of 403")))
