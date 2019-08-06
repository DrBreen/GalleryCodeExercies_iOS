### How to run?
Nothing special, just clone the repo and run the code.

### What about the server side?
Before running the application, gallery service should  run on `localhost:4555`. You can read more about how to do this in server side `README.md` itself.

### What if I want to use another server?
Change `http://localhost:4555` in `Dependencies/Assembly/RootComponentAssembly.swift` to any URL you want.

### Why was paging removed from the application?
Paging was removed because I designed it incorrectly from the start. Paging by count and offset is suitable for static data, like search results, but it's unsuitable for dynamic data, like gallery with image uploading.

### What are potential improvements?
- Redesign of paging (both server side and client side)
- Don't rely on client side figuring out if data sent by server is actually an image - send Content-Type from server for the image
- Cache images by their IDs.
