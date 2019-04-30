import Foundation

extension Array {
    func tb_rotate() -> Array {
        let arrayCount = self.count
        var result = Array()

        var baseIndex = 0

        while baseIndex < (arrayCount - 2) {
            let itemToInsert = self[baseIndex + 1]
            result.append(itemToInsert)
            baseIndex = baseIndex + 1
        }
        result.append(self[0])

        return result
    }
}
