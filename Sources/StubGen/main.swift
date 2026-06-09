import Foundation
import PathKit
import PySwift2Python

// Usage: pyswift2python <output_dir> <swift_file> [<swift_file> ...]
//
// Reads the given Swift source files, generates .pyi stubs for all @PyModule
// structs found, and writes them to <output_dir>.

let args = CommandLine.arguments.dropFirst() // drop executable name

guard args.count >= 2 else {
    fputs("usage: pyswift2python <output_dir> <swift_file> [<swift_file> ...]\n", stderr)
    exit(1)
}

let outputDir = Path(args.first!)
let inputFiles = Array(args.dropFirst()).map { Path($0) }

do {
    if !outputDir.exists {
        try outputDir.mkpath()
    }

    let result = try handleFiles(files: inputFiles)

    for fileOutput in result.outputs {
        let filename = fileOutput.name.hasSuffix(".pyi") ? fileOutput.name : "\(fileOutput.name).pyi"
        let dest = outputDir + Path(filename)
        try dest.write(fileOutput.content, encoding: .utf8)
        print("[pyswift2python] wrote \(dest)")
    }
} catch {
    fputs("[pyswift2python] error: \(error)\n", stderr)
    exit(1)
}
