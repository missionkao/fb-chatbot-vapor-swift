import Vapor

let app = Application()

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

// Print what link to visit for default port
print("Visit http://localhost:8080")
app.start(port: 8080)
