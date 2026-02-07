/** SignalingRoom Durable Object - Manages WebRTC signaling for a single chat room */
export declare class SignalingRoom implements DurableObject {
    private state;
    private peers;
    constructor(state: DurableObjectState);
    fetch(request: Request): Promise<Response>;
    private handleJoin;
    private handleSignal;
    private handleListPeers;
    private handleLeave;
}
//# sourceMappingURL=room.d.ts.map