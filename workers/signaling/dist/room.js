/** SignalingRoom Durable Object - Manages WebRTC signaling for a single chat room */
export class SignalingRoom {
    state;
    peers;
    constructor(state) {
        this.state = state;
        this.peers = new Map();
    }
    async fetch(request) {
        const url = new URL(request.url);
        const path = url.pathname;
        switch (path) {
            case '/join':
                return this.handleJoin(request);
            case '/signal':
                return this.handleSignal(request);
            case '/peers':
                return this.handleListPeers();
            case '/leave':
                return this.handleLeave(request);
            default:
                return new Response('Not Found', { status: 404 });
        }
    }
    async handleJoin(request) {
        const { peerId, publicKey } = await request.json();
        if (!peerId || !publicKey) {
            return new Response('Missing peerId or publicKey', {
                status: 400
            });
        }
        this.peers.set(peerId, {
            peerId,
            publicKey,
            joinedAt: Date.now(),
            lastSeen: Date.now()
        });
        await this.state.storage.put('peers', Array.from(this.peers));
        return new Response(JSON.stringify({
            success: true,
            peers: Array.from(this.peers.values())
        }), {
            headers: { 'Content-Type': 'application/json' }
        });
    }
    async handleSignal(request) {
        const signal = await request.json();
        const { targetPeerId, senderPeerId, data } = signal;
        if (!targetPeerId || !senderPeerId || !data) {
            return new Response('Invalid signal message', { status: 400 });
        }
        const targetPeer = this.peers.get(targetPeerId);
        if (!targetPeer) {
            return new Response('Target peer not found', { status: 404 });
        }
        targetPeer.lastSeen = Date.now();
        await this.state.storage.put('peers', Array.from(this.peers));
        return new Response(JSON.stringify({
            success: true,
            message: 'Signal queued for delivery'
        }), {
            headers: { 'Content-Type': 'application/json' }
        });
    }
    async handleListPeers() {
        return new Response(JSON.stringify({
            peers: Array.from(this.peers.values())
        }), {
            headers: { 'Content-Type': 'application/json' }
        });
    }
    async handleLeave(request) {
        const { peerId } = await request.json();
        this.peers.delete(peerId);
        await this.state.storage.put('peers', Array.from(this.peers));
        return new Response(JSON.stringify({
            success: true
        }), {
            headers: { 'Content-Type': 'application/json' }
        });
    }
}
//# sourceMappingURL=room.js.map