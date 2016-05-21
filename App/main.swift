import Vapor
import Foundation

class Message {
    var textString: String?
    var sendJson: [String: AnyObject]?
    
    init(message: Json) {
        let senderJson: [String:Json] = (message["sender"]?.object)!
        let messageJson: [String:Json]? = message["message"]?.object
        if let messageJson = messageJson {
            self.textString = messageJson["text"]?.string
        }
        let idJson: [String:String] = ["id": (senderJson["id"]?.string)!]
        if let textString = self.textString {
            let textJson: [String:String] = ["text": textString]
            self.sendJson = ["recipient": idJson, "message": textJson]
        }
    }
}

let app = Application()
let PAGE_ACCESS_TOKEN = ""

app.get("/") { request in
	return "Hello Vapor!!"
}

app.get("fbwebhook") { request in
    print("get webhook")
    guard let token = request.data["hub.verify_token"]?.string else {
        throw Abort.badRequest
    }
    guard let response = request.data["hub.challenge"]?.string else {
        throw Abort.badRequest
    }
    
    if token == "2318934571" {
        print("send response")
        return Response(status: .ok, text: response)
    } else {
        return Response(status: .ok, text: "Error, invalid token")
    }
}

app.post("fbwebhook") { request in
    print("Start")
    let url = "https://graph.facebook.com/v2.6/me/messages?access_token=" + PAGE_ACCESS_TOKEN
    var body = request.body
    let data = try body.becomeBuffer()
    let json: Json = try Json.deserialize(String(data: data))
    let entryArray: [Json] = (json["entry"]?.array)!
    let entry: Json = entryArray[0]
    let messageArray: [Json] = (entry["messaging"]?.array)!
    let messageJson: Json = messageArray[0]
    
    print(messageJson.description)
    let message: Message = Message(message: messageJson)
    if let sendJson = message.sendJson {
        let jsonData: NSData = try! NSJSONSerialization.data(withJSONObject: sendJson, options: NSJSONWritingOptions.prettyPrinted)
        let urlRequest = NSMutableURLRequest(url: NSURL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        let session = NSURLSession.shared()
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let err = error {
                return
            }
        })
        task.resume()
    } else {
        return Response(status: .ok, text: "error")
    }
    return Response(status: .ok, text: "text message")
}

// Print what link to visit for default port
print("Visit http://localhost:8080")
app.start(port: 8080)
