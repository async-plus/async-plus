Task.init {
    do {
        let thing: Thing
        do {
            thing = try await getThing()
        } catch {
            thing = try await backupGetThing(error)
        }
        await thing.doYour()
    } catch {
        error in
        alert(error)
    }
}
