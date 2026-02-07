import { SignalingRoom } from "./room";
export { SignalingRoom };
export default {
    async fetch(request, env, ctx) {
        try {
            const url = new URL(request.url);
            const path = url.pathname;
            const roomId = url.searchParams.get("room") || "default";
            switch (path) {
                case "/health":
                    return new Response(JSON.stringify({
                        status: "healthy",
                        timestamp: Date.now(),
                        version: "1.0.0",
                    }), {
                        headers: { "Content-Type": "application/json" },
                    });
                case "/ws":
                    return handleWebSocket(request, env, roomId);
                case "/api/rooms":
                    return handleRoomAPI(request, env);
                default:
                    return routeToDurableObject(request, env, roomId);
            }
        }
        catch (error) {
            return new Response(JSON.stringify({
                error: error instanceof Error ? error.message : "Internal server error",
            }), {
                status: 500,
                headers: { "Content-Type": "application/json" },
            });
        }
    },
};
async function handleWebSocket(request, env, roomId) {
    const upgradeHeader = request.headers.get("Upgrade");
    if (upgradeHeader !== "websocket") {
        return new Response("Expected websocket", { status: 400 });
    }
    const id = env.SIGNALING_ROOMS.idFromName(roomId);
    const room = env.SIGNALING_ROOMS.get(id);
    return room.fetch(request);
}
async function handleRoomAPI(request, env) {
    if (request.method === "POST") {
        const body = await request.json();
        const roomId = body.roomId || crypto.randomUUID();
        return new Response(JSON.stringify({
            roomId,
            created: true,
            url: `wss://${request.headers.get("host")}/ws?room=${roomId}`,
        }), {
            headers: { "Content-Type": "application/json" },
            status: 201,
        });
    }
    if (request.method === "GET") {
        return new Response(JSON.stringify({
            rooms: [],
            count: 0,
        }), {
            headers: { "Content-Type": "application/json" },
        });
    }
    return new Response("Method not allowed", { status: 405 });
}
async function routeToDurableObject(request, env, roomId) {
    try {
        const id = env.SIGNALING_ROOMS.idFromName(roomId);
        const room = env.SIGNALING_ROOMS.get(id);
        return room.fetch(request);
    }
    catch (error) {
        return new Response(JSON.stringify({
            error: "Durable Object error",
            message: error instanceof Error ? error.message : "Unknown error",
        }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
}
//# sourceMappingURL=index.js.map