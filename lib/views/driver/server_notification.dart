import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:flutter/material.dart';

class PushNotificationService {

  static Future<String> getAccessToken() async {
    final serviceAccountJson = 
      {
  "type": "service_account",
  "project_id": "metroshuttle-a177e",
  "private_key_id": "cf60ac73e839cf7b1b417a4e5197ff8f7427e3f4",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCpWz8AW1OvofSg\nY/7efmYoG3Y8nTYn8FgyT4/OYAGHp+o3/usRMHjrPJ0ANNUYrxXYWUQxXxv478MZ\nbVuAu53lm2L+A0PkIIfTs3NPvNnpd6SiRxgIvptYXZkaYtcWE0MdlZCJ+52MXxeR\nuY43ysMtOITRsFJQHyGzQcx+UMDaW6S/f4WatZnuXVEXh0CRZVyXZbidaK922EPK\nxCTD0cWNd/9AM5T4NM8lKJTa3ZUAmu1/5YgGIbb0/FxmXFxvZ6dzMO2VuizMg4A0\nmJh3hD/Vg3pi6CQoQZGGaOUMr9B1QtObfPK9ND4OYE6zMCezD3vVMOm9Xp8uDVhE\npHOGvf8PAgMBAAECggEAG/83yuUjewlLlF5ONSrxKW03c9gg1U5qziUP/B6BR5NP\nPuLh/7f4gsRE8if0bdMNSfRL4oY7bMD6NaW59u333DbUER5UvA2oAVaNArVmKC3o\nELmvCUxgCFDaLXNXOlDZ4LX9LIpk5l6Wr2JdAUUq/zqfiRNchYlNUWyDFANhNlej\nLY9jL6SbncYjqoRbHNs+C/PBXQs+3q8QcasOPjzxYJQPGw+9zv1SqG0/lRRzyTa6\nTbMSFLf459NWBG27qMy6BkU4sG6RiLWdpjtQajWmxiW3GyfA4FAiVfBsMQqmhYp2\ni95Qd4z5dQnGsqCUC+cEv7el79pC3qHMabTZYzYhMQKBgQDoSQSd7tdymok+1VZY\nvJXOZtOP7k3kEr2OM1Yj9Vt7QThutmllgdEZW80ebHzpwUACcpLOmaAzWK6gE90D\nTq5HA64M1OkA4XxK+DaMZ+LNbgSR2Al7oHVGCp1nHTHkibtVuCsNDFYpFKEiH3y3\n/3GMFaMbCQU4XlB+Aw46qg8hPwKBgQC6pYcZfQQ1tV3aaGgKakVwSWDNaf7K01rc\n5I36qfV1YXv+x7uV9ZrLKC+4pcFTim+RyJjtW33nYHQk7uU/91Y2zi3Dcx10WZmo\n2x6FHZT8qHi/PfsEKXaPwvqX2XUqYO8bSM48leqHv7xygVOrA8LIRD6nmTr2VxaX\nH06Ln/zeMQKBgFqBMMJUcC+gFL+dofIbMIdmOyJGaKTnxGGmkPabv9QrWlCQ1EoP\npagqw6YKATWW7VjGyXqkEu5OrGOEucVzH6ZdwbAQOOT19lbDlYVpaM5AApnMwg0g\nPPFYa3Hkxy7Tl2FTy7pexydkeU/xUsfiSJybRZzgC9+lp9khWabz4cdDAoGBAJzd\nkXXyhB8/lumA5jAasNF2Wk1J0EJW7/7GeC07ung0vimbZCTcjoQ/+huN87Vqm+pC\nVYTnaCGWBwcjYLkp/uOA1SV3EkI/K82mmzf1bMoMLa9NQDJ3RpX8oPAOa1J6tXqQ\n7gQtWzdMBe2Wk+Me/g2ijaX+OnffKbVJMpJWnAeBAoGBALOvmt4Nu5RohcYKTQyj\nMHz7GmRMWKW3dF6jp9XjD3FGW2sfyOzZ5fwCdTKFqGQK/MvySJYcrKvncN2KaQNw\nwID9tAKoDocWr9mGEN8g55849+mMlYXn1RIEA10xszC8W33pX+cwfvwPwr3QKmJi\nDVXJimG7yki3bCKQclHtxTiH\n-----END PRIVATE KEY-----\n",
  "client_email": "metroshuttle-notifications@metroshuttle-a177e.iam.gserviceaccount.com",
  "client_id": "102530876667869950937",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/metroshuttle-notifications%40metroshuttle-a177e.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging"
  ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client
    );
  client.close();

  return credentials.accessToken.data;

  }

  static sendNotificationToDriver(String deviceToken, BuildContext context) async {

    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = "https://fcm.googleapis.com/v1/projects/metroshuttle-a177e/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': 'Hello',
          'body': 'This is a test notification'
        },
        'data': {
        //  'tripId': tripId
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String> {
        'content-type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey' 
      },
      body: jsonEncode(message)
    );

  if (response.statusCode==200) {
    print('Notification successful');
  } else {
    print('Notification Unsuccessful');
  }

  }
}