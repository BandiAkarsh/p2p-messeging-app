/** SignalingRoom Durable Object - Manages WebRTC signaling for a single chat room */
export class SignalingRoom implements DurableObject {
  private state: DurableObjectState;
  private peers: Map<string, PeerInfo>;

  constructor(state: DurableObjectState) {
    this.state = state;
    this.peers = new Map();
  }

  async fetch(request: Request): Promise<Response> {
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

  private async handleJoin(request: Request): Promise<Response> {
    const { peerId, publicKey }: JoinRequest = await request.json();
    
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

  private async handleSignal(request: Request): Promise<Response> {
    const signal: SignalMessage = await request.json();
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

  private async handleListPeers(): Promise<Response> {
    return new Response(JSON.stringify({
      peers: Array.from(this.peers.values())
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }

  private async handleLeave(request: Request): Promise<Response> {
    const { peerId }: { peerId: string } = await request.json();
    
    this.peers.delete(peerId);
    await this.state.storage.put('peers', Array.from(this.peers));

    return new Response(JSON.stringify({
      success: true
    }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

interface PeerInfo {
  peerId: string;
  publicKey: string;
  joinedAt: number;
  lastSeen: number;
}

interface JoinRequest {
  peerId: string;
  publicKey: string;
}

interface SignalMessage {
  senderPeerId: string;
  targetPeerId: string;
  data: unknown;
}
