### How to run?
Nothing special, just clone the repo and run the code.

### What about the server side?
It should connect to my server automatically.
If you want to run it locally, change `let url = resolver.resolve(URL.self, name: "baseUrl")!` to `let url = resolver.resolve(URL.self, name: "baseUrlLocalhost")!`

If running locally:
Before running the application, gallery service should  run on `localhost:4555`. You can read more about how to do this in server side `README.md` itself.

### What if I want to use another server?
Change `http://localhost:4555` in `Dependencies/Assembly/RootComponentAssembly.swift` to any URL you want.
For example, you can use `http://142.93.165.77:4555`, which is my server.

### Why was paging removed from the application?
Paging was removed because I designed it incorrectly from the start. Paging by count and offset is suitable for static data, like search results, but it's unsuitable for dynamic data, like gallery with image uploading.

### What are potential improvements?
- Redesign of paging (both server side and client side)
- Don't rely on client side figuring out if data sent by server is actually an image - send Content-Type from server for the image
- Cache images by their IDs.
- Cache invalidation by ID instead of the whole cache. (this can be useful after editing image)
