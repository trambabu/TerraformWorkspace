// Change this in one place only
/*const CONFIG = {
    API_BASE: "http://localhost:8080/orders" // replace with real endpoint when needed
};

*/


// Auto-switch API_BASE depending on environment
const CONFIG = {
    API_BASE: (function() {
        const host = window.location.hostname;
        if (host === "localhost" || host === "127.0.0.1") {
            return "http://localhost:8080/orders"; // development API
        } else {
            return "https://api.yourdomain.com/orders"; // production API
        }
    })()
};

/*
// Define environment endpoints
const ENVIRONMENTS = {
    dev: "http://localhost:8080/orders",
    staging: "https://staging-api.yourdomain.com/orders",
    prod: "https://api.yourdomain.com/orders"
};

// Detect environment automatically or set manually
const ENV = (function() {
    const host = window.location.hostname;

    if (host === "localhost" || host === "127.0.0.1") return "dev";
    if (host.includes("staging")) return "staging";
    return "prod";
})();

const CONFIG = {
    API_BASE: ENVIRONMENTS[ENV]
};
*/

/*

// Choose environment: 'dev', 'staging', 'prod'
const ENV = "dev";  // <-- change this to 'staging' or 'prod' when needed

// Define environment endpoints
const ENVIRONMENTS = {
    dev: "http://localhost:8080/orders",
    staging: "https://staging-api.yourdomain.com/orders",
    prod: "https://api.yourdomain.com/orders"
};

const CONFIG = {
    API_BASE: ENVIRONMENTS[ENV]
};

*/