# TheHouse - Amazon Echo Companion Server

An Amazon Echo (Alexa) Companion Server for the RaspberryPi, or other in-house hardware. It currently works with
RepetierServer, KODI, and as a general screen reader.

===============================

##Setup:

**1. Get the latest version:**

```
git clone https://github.com/bg-wa/thehouse.git
```

**2. Configure which libraries you'd like to use**
 You can easily add/remove individual libraries in `application_controller.rb`.
     Helper libraries are found at (and can be added to): `app/helpers/`**

```
  include RepetierserverHelper
  include KodiHelper
  include PageReaderHelper
```

**3. Create Your Amazon Alexa Skills**

You'll need to create a unique skill in the Amazon Developer Portal, for each library, pointing to your domain and using
your SSL.

- **Skill Information**

    ![Alt text](lib/assets/readme/skill_information.png?raw=true "Skill Information")

- **Interaction Model**

    Stored in `lib/amazon/[library]`.  Copy/Paste into appropriate field.

    ![Alt text](lib/assets/readme/interaction_model.png?raw=true "Interaction Model")

- **Configuration**

    You'll need to point the skill to your home IP or domain using HTTPS.

    ![Alt text](lib/assets/readme/configuration.png?raw=true "Configuration")

- **Skill Information**

    ![Alt text](lib/assets/readme/skill_information.png?raw=true "Skill Information")

- **SSL Certificate**

    This Self-signed Certificate will need to be installed on the pi/server, your dev machine, and copied into the skill
    settings.  The same SSL cert will be used for all skills.

    ![Alt text](lib/assets/readme/ssl_certificate.png?raw=true "SSL Certificate")

**4. Set your environment variables**

For the default libraries, you'll need to create environment variables for:

```
ALEXA_SKILL_ID_1
ALEXA_SKILL_ID_2
ALEXA_SKILL_ID_3
REPETIER_HOST_API_KEY
```

**5. Start your server**

```
rails s
```

**6. Routing.**

Make sure your network properly routes HTTPS traffic to your pi/server by using the **Test** tab on the left side of
your skill configuration.

##Data Workflow
**Human** => Alexa => Amazon Developer Portal Skill => your-domain[:443] => `application_controller.rb`

```
_APP LOGIC_
filter request by TYPE ('LaunchRequest', 'IntentRequest') then
filter request by SKILL APPLICATION ID then
pass request to HELPER

filter by INTENT*
Preform ACTION (API REQUSET HERE)*
get RESPONSE
assign alexa_response_text as STRING

*('intentRequest' TYPE only)
```

Application response => Alexa => **Human**

##Notes

* I've mainly used this with my 3D printer, so the KODI and screen reader are less tested and unfinished.

**Contributions:**

The basic premise of this application is pretty simple and the current workflow is pretty scalable, so feel free to add
helper libraries, report/fix bugs, or add documentation where you think concepts are unclear.