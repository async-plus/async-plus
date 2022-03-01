# Operations

Following is a full list of supported chaining operations in Async+:

**attempt**

**then**

**recover**

```
let Result<photo> = attempt {
    return await api.getPhoto()
}.recover {
    err in
    return await cache.getPhoto()
}.then {
    photo in
    try displayPhotoToUser(photo)
}
```

**ensure**

**catch**

**finally**