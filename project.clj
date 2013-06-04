(defproject reno-2 "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [compojure "1.1.5"]
                 [com.novemberain/monger "1.6.0-beta2"]
                 [ring/ring-json "0.2.0"]
                 [clj-aws-s3 "0.3.6"]
                 [clj-time "0.5.1"]
                 [clojurewerkz/scrypt "1.0.0"]]
  :plugins [[lein-ring "0.8.5"]]
  :ring {:handler reno-2.handler/app}
  :profiles
  {:dev {:dependencies [[ring-mock "0.1.5"]]}})
