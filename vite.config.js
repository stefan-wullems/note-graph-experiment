import { defineConfig } from "vite"
import elmPlugin from "vite-plugin-elm"

// paths are relative to the root of `frontend-elm`
export default defineConfig({
    // identify what plugins we want to use
    root: "./src",
    plugins: [elmPlugin()],
    server: {

    },
    // configure our build
    build: {
        // file path for the build output directory
        outDir: "../../dist",
        // esbuild target
        target: "es2020"
    }
})