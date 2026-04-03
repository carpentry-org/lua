-- application configuration
app = {
    name = "my-service",
    port = 8080,
    debug = true,
}

function greeting()
    return "hello from " .. app.name
end
