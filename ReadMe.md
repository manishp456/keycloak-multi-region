
<img width="625" height="452" alt="image" src="https://github.com/user-attachments/assets/6d054714-68ef-47e9-a8ea-f1f78bce2edd" />


Check if the docker process is running using the below command 
   docker ps
   

   
Map hostnames to localhost configured in Docker file
   Edit your local hosts file located in C:\Windows\System32\drivers\etc directory in Notepad (as admin)
   
   Add these lines at the bottom:
   127.0.0.1   keycloak-global.local
   127.0.0.1   keycloak-bangalore.local
   
Save and exit.

This means:

  - Both hostnames resolve to your local machine.
  - The browser will still treat them as different origins because cookies and sessions are domain-scoped (they depend on the hostname, not the IP).

So, even though they share the same IP (localhost), your browser considers them independent sites.
That’s exactly why this trick works — it breaks cookie/session collisions between the two Keycloak servers.

Without updating the hosts file in C:\Windows\System32\drivers\etc directory, the real problem was 
  
  When you ran two Keycloak servers on different ports (9000 and 9090), both
     - Exposed the same base URL (http://localhost:8080) internally.
	 - Issued cookies scoped to localhost.
	 - Redirected OAuth flows to http://localhost:8080.

  This caused:
     Session cookie collisions (browser saw both as “localhost” and reused tokens).
     Redirect errors because each Keycloak instance thought it “owned” the same domain.
     You could only be logged into one Keycloak instance at a time.

The below command helps you to run the keycloak-multi-region setup.
   docker compose up -d
   
Logs can be viewed by issueing command 
   docker compose logs -f keycloak
   
   docker logs postgres-global
   
Check from inside the Keycloak container:
   docker exec -it keycloak-global bash
   ping postgres-global   

Access both Keycloaks independently
   Global instance: 
                     http://keycloak-global.local:9000/admin
   Bangalore instance: 
                     http://keycloak-bangalore.local:9090/admin
   
Both will now work simultaneously, with separate sessions and cookies.

   
   
docker compose stop  -> If you want to stop but keep data

docker compose down -v -> If you want a clean start (remove all volumes too)

docker exec -it postgres-global psql -U superuser -d global_db_instance
 
 \l
 \du

The below command will help you login and change the codepage to 1252 for smooth running of queries.
  psql -U superuser -d global_db_instance
  chcp 1252


psql -U postgres
<password>

DROP DATABASE database_name;
CREATE DATABASE global_db_instance;
CREATE DATABASE bangalore_db_instance;

CREATE DATABASE global_db_instance WITH OWNER = superuser;
CREATE USER superuser WITH PASSWORD 'keycloak@123';

DROP ROLE superuser;
CREATE ROLE superuser WITH LOGIN PASSWORD 'keycloak@123' SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS;

CREATE DATABASE global_db_instance WITH OWNER=superuser ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE = template0;
CREATE DATABASE bangalore_db_instance WITH OWNER=superuser ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE = template0;






