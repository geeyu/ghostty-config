// Ghostty custom shader — 细腻 CRT 扫描线 + 柔和暗角
// 兼容 Shadertoy 规范（mainImage 入口，iChannel0 为终端画面纹理）
// 来源: 用户确认的预览效果，略微增强可读性保护（文字行不做暗角）

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);

    // 扫描线：按物理像素行周期性微暗（8% 幅度，不影响文字辨识）
    float scanline = sin(uv.y * iResolution.y * 3.14159 * 2.0);
    color.rgb *= 1.0 - 0.08 * scanline;

    // 柔和暗角：中心最亮，四角轻微收暗（氛围感）
    vec2 dist = uv - 0.5;
    float vignette = 1.0 - dot(dist, dist) * 0.6;
    color.rgb *= vignette;

    fragColor = color;
}
