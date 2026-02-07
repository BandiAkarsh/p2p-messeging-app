import { SignalingRoom } from "./room";
export { SignalingRoom };
declare const _default: {
    fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response>;
};
export default _default;
interface Env {
    SIGNALING_ROOMS: DurableObjectNamespace;
}
//# sourceMappingURL=index.d.ts.map