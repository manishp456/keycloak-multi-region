
<img width="625" height="452" alt="image" src="https://github.com/user-attachments/assets/6d054714-68ef-47e9-a8ea-f1f78bce2edd" />



Check if the docker process is running using the below command 
   docker ps
   

   
Map hostnames to localhost configured in Docker file
   Edit your local __hosts__ file located in __C:\Windows\System32\drivers\etc__ directory in Notepad (as admin)
   
   Add these lines at the bottom:
   
   127.0.0.1   keycloak-global.local
   
   127.0.0.1   keycloak-bangalore.local
   
Save and exit.

This means:

  - Both hostnames resolve to your local machine.
  - The browser will still treat them as different origins because cookies and sessions are domain-scoped (they depend on the hostname, not the IP).

So, even though they share the same IP (localhost), your browser considers them independent sites.
That’s exactly why this trick works — it breaks cookie/session collisions between the two Keycloak servers.

Without updating the __hosts__ file in __C:\Windows\System32\drivers\etc__ directory, the real problem was 
  
  When you ran two Keycloak servers on different ports (9000 and 9090), both
  
     - Exposed the same base URL (http://localhost:8080) internally.
	 
	 - Issued cookies scoped to localhost.
	 
	 - Redirected OAuth flows to http://localhost:8080.

  This caused:
  
     Session cookie collisions (browser saw both as “localhost” and reused tokens).
     Redirect errors because each Keycloak instance thought it “owned” the same domain.
     You could only be logged into one Keycloak instance at a time.

The below command helps you to run the keycloak-multi-region setup.

   __docker compose up -d__
   
Logs can be viewed by issueing command

   __docker compose logs -f keycloak__
   
   __docker logs postgres-global__
   
Check from inside the Keycloak container:
   
   __docker exec -it keycloak-global bash__
   __ping postgres-global__   

Access both Keycloaks independently
   Global instance:
   
                     http://keycloak-global.local:9000/admin
   Bangalore instance:
   
                     http://keycloak-bangalore.local:9090/admin
   
Both will now work simultaneously, with separate sessions and cookies.

   
   
__docker compose stop__   If you want to stop but keep data

__docker compose down -v__  If you want a clean start (remove all volumes too)

__docker exec -it postgres-global psql -U superuser -d global_db_instance__ will help you navigate to __postgres-global__ instance
 
 __\l__
 
 __\du__

The below command will help you login and change the codepage to 1252 for smooth running of queries.
  
  __psql -U superuser -d global_db_instance__
  __chcp 1252__

If you want to connect to postgres instance locally, then use the below command.

__psql -U postgres__
__<password>__

Postgres commands which you can use to create/drop database, user , roles.

DROP DATABASE database_name;

CREATE DATABASE global_db_instance;

CREATE DATABASE bangalore_db_instance;

CREATE DATABASE global_db_instance WITH OWNER = superuser;

CREATE USER superuser WITH PASSWORD 'keycloak@123';

DROP ROLE superuser;

CREATE ROLE superuser WITH LOGIN PASSWORD 'keycloak@123' SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS;

CREATE DATABASE global_db_instance WITH OWNER=superuser ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE = template0;

CREATE DATABASE bangalore_db_instance WITH OWNER=superuser ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE = template0;






