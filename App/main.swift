import Vapor

let app = Application()

app.get("/") { request in
	return "Hello Vapor!!"
}

// Print what link to visit for default port
print("Visit http://localhost:8080")
app.start(port: 8080)
