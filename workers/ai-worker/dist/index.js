export default {
    async fetch(request, env, ctx) {
        try {
            const url = new URL(request.url);
            const path = url.pathname;
            switch (path) {
                case "/health":
                    return handleHealth(env);
                case "/smart-reply":
                    return handleSmartReply(request, env);
                case "/translate":
                    return handleTranslate(request, env);
                case "/summarize":
                    return handleSummarize(request, env);
                case "/detect-language":
                    return handleDetectLanguage(request, env);
                default:
                    return new Response("Not Found", { status: 404 });
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
async function handleHealth(env) {
    return new Response(JSON.stringify({
        status: "healthy",
        service: "ai-worker",
        timestamp: Date.now(),
        version: "1.0.0",
        aiAvailable: !!env.AI,
    }), {
        headers: { "Content-Type": "application/json" },
    });
}
async function handleSmartReply(request, env) {
    if (request.method !== "POST") {
        return new Response("Method not allowed", { status: 405 });
    }
    if (!env.AI) {
        return new Response(JSON.stringify({
            error: "AI service not available",
        }), { status: 503 });
    }
    const body = await request.json();
    const { message, context, tone = "friendly" } = body;
    if (!message) {
        return new Response("Message required", { status: 400 });
    }
    const prompt = `Given this message: "${message}"
Context: ${context || "casual conversation"}
Tone: ${tone}

Generate 3 short, natural reply suggestions (max 10 words each):
1. [reply]
2. [reply]
3. [reply]`;
    try {
        const response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
            messages: [{ role: "user", content: prompt }],
            max_tokens: 256,
        });
        const suggestions = parseSuggestions(response.response || "");
        return new Response(JSON.stringify({
            success: true,
            message,
            suggestions,
            model: "@cf/meta/llama-3.1-8b-instruct",
        }), {
            headers: { "Content-Type": "application/json" },
        });
    }
    catch (error) {
        return new Response(JSON.stringify({
            success: false,
            error: error instanceof Error ? error.message : "AI request failed",
        }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
}
async function handleTranslate(request, env) {
    if (request.method !== "POST") {
        return new Response("Method not allowed", { status: 405 });
    }
    if (!env.AI) {
        return new Response(JSON.stringify({
            error: "AI service not available",
        }), { status: 503 });
    }
    const body = await request.json();
    const { text, targetLang, sourceLang } = body;
    if (!text || !targetLang) {
        return new Response("Text and targetLang required", { status: 400 });
    }
    const prompt = `Translate this text to ${targetLang}:
"${text}"

${sourceLang ? `Source language: ${sourceLang}` : "Detect source language"}

Translation:`;
    try {
        const response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
            messages: [{ role: "user", content: prompt }],
            max_tokens: 256,
        });
        return new Response(JSON.stringify({
            success: true,
            original: text,
            translation: (response.response || "").trim(),
            targetLang,
        }), {
            headers: { "Content-Type": "application/json" },
        });
    }
    catch (error) {
        return new Response(JSON.stringify({
            success: false,
            error: error instanceof Error ? error.message : "Translation failed",
        }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
}
async function handleSummarize(request, env) {
    if (request.method !== "POST") {
        return new Response("Method not allowed", { status: 405 });
    }
    if (!env.AI) {
        return new Response(JSON.stringify({
            error: "AI service not available",
        }), { status: 503 });
    }
    const body = await request.json();
    const { text, maxLength = 100 } = body;
    if (!text) {
        return new Response("Text required", { status: 400 });
    }
    const prompt = `Summarize the following conversation in ${maxLength} words or less:

${text.substring(0, 2000)}

Summary:`;
    try {
        const response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
            messages: [{ role: "user", content: prompt }],
            max_tokens: 256,
        });
        return new Response(JSON.stringify({
            success: true,
            originalLength: text.length,
            summary: (response.response || "").trim(),
        }), {
            headers: { "Content-Type": "application/json" },
        });
    }
    catch (error) {
        return new Response(JSON.stringify({
            success: false,
            error: error instanceof Error ? error.message : "Summarization failed",
        }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
}
async function handleDetectLanguage(request, env) {
    if (request.method !== "POST") {
        return new Response("Method not allowed", { status: 405 });
    }
    if (!env.AI) {
        return new Response(JSON.stringify({
            error: "AI service not available",
        }), { status: 503 });
    }
    const body = await request.json();
    const { text } = body;
    if (!text) {
        return new Response("Text required", { status: 400 });
    }
    const prompt = `Detect the language of this text and respond with only the ISO 639-1 code:

"${text.substring(0, 500)}"

Language code:`;
    try {
        const response = await env.AI.run("@cf/meta/llama-3.1-8b-instruct", {
            messages: [{ role: "user", content: prompt }],
            max_tokens: 10,
        });
        const langCode = (response.response || "").trim().toLowerCase();
        return new Response(JSON.stringify({
            success: true,
            text: text.substring(0, 100),
            language: langCode,
            confidence: "high",
        }), {
            headers: { "Content-Type": "application/json" },
        });
    }
    catch (error) {
        return new Response(JSON.stringify({
            success: false,
            error: error instanceof Error ? error.message : "Language detection failed",
        }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
}
function parseSuggestions(response) {
    const lines = response.split("\n");
    const suggestions = [];
    for (const line of lines) {
        const match = line.match(/^\d+\.\s*(.+)$/);
        if (match) {
            suggestions.push(match[1].trim());
        }
    }
    return suggestions.length > 0 ? suggestions : [response.trim()];
}
//# sourceMappingURL=index.js.map