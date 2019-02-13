# Remote Config POC
# 
>  Solution for native swift.Mean, change service url or important text , or title no required app publish apple store so remote config modify params and share config after client url changed.

# Demo

![Remote Config](https://github.com/VB10/RemoteConfigPOC/blob/master/Demos/remoteconfigios.gif?raw=true)

#How To Work?

- App first start get config and save device db & cache
- App runtime during, any call api add header "parms versionNumber:15" 
-  If success return 200 and model data 
- Else fail return 426 code (custom) and new version body (look at example .json)


**Get config**
HTTP 200 No Error
```json
{
  "parameters": {
    "title": {
      "defaultValue": {
        "value": "Homepage"
      }
    },
    "description": {
      "defaultValue": {
        "value": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
      }
    },
    "website": {
      "defaultValue": {
        "value": "https://www.hackerrank.com/"
      }
    }
  },
  "version": {
    "versionNumber": "30",
    "updateTime": "2019-02-13T06:10:58.665Z",
    "updateUser": {
      "email": "***@***.com"
    },
    "updateOrigin": "CONSOLE",
    "updateType": "INCREMENTAL_UPDATE"
  }
}
```

**Get config versionNumber**

HTTP 426 Client Error
Content-Type: application/json
Accept: */*
versionNumber: Value
```json
{
  "parameters": {
    "title": {
      "defaultValue": {
        "value": "Homepage"
      }
    },
    "description": {
      "defaultValue": {
        "value": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
      }
    },
    "website": {
      "defaultValue": {
        "value": "https://www.hackerrank.com/"
      }
    }
  },
  "version": {
    "versionNumber": "30",
    "updateTime": "2019-02-13T06:10:58.665Z",
    "updateUser": {
      "email": "***@***.com"
    },
    "updateOrigin": "CONSOLE",
    "updateType": "INCREMENTAL_UPDATE"
  }
}

```
HTTP 200
```text
student1
```