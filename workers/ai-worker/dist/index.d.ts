declare const _default: {
    fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response>;
};
export default _default;
interface Env {
    AI: Ai;
    MAX_TOKENS: string;
}
interface Ai {
    run(model: string, inputs: {
        messages: {
            role: string;
            content: string;
        }[];
        max_tokens: number;
    }): Promise<{
        response: string;
    }>;
}
//# sourceMappingURL=index.d.ts.map