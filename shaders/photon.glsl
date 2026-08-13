// Ghostty custom shader — Gruvbox 琥珀光子特效
// 效果：边缘光子流光 + 背景游荡光斑（四边弹性反弹）+ 光标暖光晕 + 轻扫描线 + 柔和暗角
// Shadertoy 兼容（mainImage 入口，iChannel0 = 终端画面纹理）
// uniform 参考: iTime / iResolution / iCurrentCursor / iFocus

// 确定性伪随机：同一粒子索引永远得到同样的“个性”，时间只负责推进运动
float hash1(float n) { return fract(sin(n * 127.1) * 43758.5453); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);
    float t = iTime;

    // Gruvbox 暖色系（再提一档）
    vec3 amber = vec3(0.95, 0.70, 0.17);   // 亮金黄
    vec3 ember = vec3(0.96, 0.48, 0.10);   // 亮橙
    vec3 flame = vec3(0.88, 0.33, 0.11);   // 亮火红（渐变终点）

    // ── 1. 边缘光子流光 ─────────────────────────────
    // 距最近边缘的距离 → 边框区域掩码
    vec2 edgeDist = min(uv, 1.0 - uv);
    float borderDist = min(edgeDist.x, edgeDist.y);
    float border = 1.0 - smoothstep(0.0, 0.02, borderDist);

    // 沿边框逆时针的周长坐标 p ∈ [0,4)：
    //   下边=uv.x  右边=1+uv.y  上边=2+(1-uv.x)  左边=3+(1-uv.y)
    // 用四边权重平滑混合，转角处相位连续 → 光斑无缝绕行不卡角
    float wL = 1.0 - smoothstep(0.0, 0.04, edgeDist.x);
    float wR = 1.0 - smoothstep(0.0, 0.04, 1.0 - uv.x);
    float wB = 1.0 - smoothstep(0.0, 0.04, uv.y);
    float wT = 1.0 - smoothstep(0.0, 0.04, 1.0 - uv.y);
    float p = (
        wL * (3.0 + (1.0 - uv.y)) +
        wR * (1.0 + uv.y) +
        wB * uv.x +
        wT * (2.0 + (1.0 - uv.x))
    ) / max(wL + wR + wB + wT, 1e-5);

    // 两团光斑沿边框匀速绕行（速度放慢，t*2.0 ≈ 3 秒绕一圈）
    float flow = 0.5 + 0.5 * sin(p * 1.5708 - t * 2.0);

    // 渐变配色：沿边框 金 → 橙 → 火红 一圈，缓慢流转（20 秒转一圈）
    float g = fract(p * 0.25 + t * 0.05);
    vec3 photon = mix(amber, ember, smoothstep(0.0, 0.5, g));
    photon = mix(photon, flame, smoothstep(0.5, 1.0, g));

    // 整体呼吸：放慢到 ~5 秒一次，幅度收敛更柔和
    float breath = 0.78 + 0.22 * sin(t * 1.2);
    color.rgb += border * flow * flow * photon * 0.28 * breath;

    // ── 1.5 背景游荡光斑（物理：四边弹性反弹 + 各自游速/尺寸/明暗）────
    for (int i = 0; i < 6; i++) {
        float fi = float(i);
        // 每颗粒子的固定“个性”（只由索引决定，不随时间变化）
        vec2 pos0 = vec2(hash1(fi * 12.99 + 3.14), hash1(fi * 4.89 + 1.41));
        vec2 vel  = (vec2(hash1(fi * 7.77 + 2.71), hash1(fi * 3.33 + 9.87)) - 0.5)
                    * (0.03 + 0.05 * hash1(fi * 6.66 + 8.88));   // 各自游速不同
        float size   = 0.02 + 0.05 * hash1(fi * 9.99 + 5.55);
        float bright = 0.12 + 0.16 * hash1(fi * 5.55 + 4.44);

        // 折返映射：直线运动在 [0,1]² 边界弹性反弹，像撞墙后弹回
        vec2 p = abs(fract(pos0 + vel * t) * 2.0 - 1.0);

        // 圆形高斯光斑（乘宽高比修正，非正方形窗口下也是正圆）
        vec2 dd = (uv - p) * vec2(iResolution.x / max(iResolution.y, 1.0), 1.0);
        float glow = exp(-dot(dd, dd) / (size * size));

        // 颜色在金/橙之间随机；各自缓慢明灭（错峰，更自然）
        vec3 pc = mix(amber, ember, hash1(fi * 2.22 + 6.54));
        float twinkle = 0.65 + 0.35 * sin(t * 0.8 + fi * 1.7);
        color.rgb += pc * glow * bright * twinkle;
    }

    // ── 2. 光标暖光晕（光子核心）────────────────────
    // iCurrentCursor.xy = 光标角点（y 向上），zw = 宽高；uv 原点在左上 → 翻转 y
    vec2 curCenter = iCurrentCursor.xy + iCurrentCursor.zw * 0.5;
    vec2 curUv = vec2(
        curCenter.x / max(iResolution.x, 1.0),
        1.0 - curCenter.y / max(iResolution.y, 1.0)
    );
    float d = distance(uv, curUv);
    float glow = exp(-d * d * 800.0);          // 柔和高斯光晕
    float focus = (iFocus > 0) ? 1.0 : 0.3;    // 非聚焦时减弱
    color.rgb += amber * glow * 0.38 * focus;
    // 光标下方一点微光拖尾
    float trail = exp(-d * d * 200.0);
    color.rgb += ember * trail * 0.11 * focus;

    // ── 3. 轻扫描线 + 柔和暗角（护眼保留）──────────
    float scanline = sin(uv.y * iResolution.y * 3.14159 * 2.0);
    color.rgb *= 1.0 - 0.03 * scanline;
    vec2 dv = uv - 0.5;
    color.rgb *= 1.0 - dot(dv, dv) * 0.42;

    fragColor = color;
}
