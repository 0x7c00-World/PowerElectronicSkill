% bode74.m — 7.4 节 Boost Gvd 真实 Bode 图
% 数值：Vg=24, Vo=48, Io=2A, R=24, L=150u, C=220u, rC=50m, fsw=100k, D=D'=0.5
clear; clc;

Vg = 24; Dp = 0.5; L = 150e-6; C = 220e-6; rC = 50e-3; R = 24; fsw = 100e3;

f = logspace(2, 5.35, 2000).';            % 100 Hz ~ 224 kHz
w = 2*pi*f; s = 1j*w;

w0  = Dp/sqrt(L*C);                        % 2752 rad/s  (438 Hz)
Q   = R*Dp*sqrt(C/L);                      % 14.5
wz  = R*Dp^2/L;                            % 40 krad/s   (6.37 kHz, RHP)
wzc = 1/(rC*C);                            % 91 krad/s   (14.5 kHz, ESR)
Gdo = Vg/Dp^2;                             % 96 (39.7 dB)

% 标准形式（7.3）：RHP 零点 (1−s/wz)；ESR 零点按特征频率表叠加 (1+s/wzc)
Gvd = Gdo * (1 - s/wz) .* (1 + s/wzc) ./ (1 + s/(Q*w0) + (s/w0).^2);
Gvg = (1/Dp) ./ (1 + s/(Q*w0) + (s/w0).^2);   % 7.3 末：同分母、分子干净

% 解析相位（避免高 Q 谐振处 unwrap 断裂）：各因子相位连续求和
fc    = 1e3;
i_fc  = find(f>=fc,1);
x     = w/w0;
denph = atan2(w/(Q*w0), 1 - x.^2);                    % 双重极点：0→180° 连续
phvd  = -atan(w/wz) + atan(w/wzc) - denph;            % Gvd 相位（弧度）
phvg  = -denph;                                       % Gvg 相位
mag_fc = 20*log10(abs(Gvd(i_fc)));
ph_fc  = rad2deg(phvd(i_fc));

cBlue=[24 95 165]/255; cGray=[110 108 102]/255; cGreen=[59 109 17]/255; cRed=[153 60 29]/255;

fig = figure('Visible','off','Position',[1 1 9.2 6.6],'Color','w');

subplot(2,1,1);
semilogx(f, 20*log10(abs(Gvd)), 'Color', cBlue, 'LineWidth', 1.8); hold on;
semilogx(f, 20*log10(abs(Gvg)), '--', 'Color', cGray, 'LineWidth', 1.4);
xline(w0/(2*pi), ':', 'Color', cGray, 'LineWidth', 1);   % f0
xline(wz/(2*pi), ':', 'Color', cRed, 'LineWidth', 1.2);        % frhpz
xline(fsw/2, '--', 'Color', cRed, 'LineWidth', 1.2);           % fsw/2
plot(f(i_fc), mag_fc, 'o', 'Color', cGreen, 'MarkerSize', 7, 'MarkerFaceColor', cGreen);
text(f(i_fc)*1.15, mag_fc+9, sprintf('f_c = 1 kHz: %.1f dB / %.0f°', mag_fc, ph_fc), 'Color', cGreen, 'FontSize', 9);
i_pk = find(abs(Gvd)==max(abs(Gvd)),1);
text(f(i_pk)*1.08, 20*log10(abs(Gvd(i_pk)))+2.5, sprintf('Q 峰 +%.0f dB @ %.0f Hz', 20*log10(abs(Gvd(i_pk)))-20*log10(Gdo), f(i_pk)), 'Color', cBlue, 'FontSize', 9);
text(wz/(2*pi)*1.15, -33, 'f_{rhpz} 6.4k：斜率 −40 → −20', 'Color', cRed, 'FontSize', 9);
ylim([-40 70]); grid on; box on; set(gca,'FontSize',9.5);
ylabel('|G| (dB)');
title('Boost 算例（24→48 V）：G_{vd} 与 G_{vg}（按 7.3 公式计算，含 ESR 零点）');
legend('G_{vd}（控制到输出）','G_{vg}（线到输出，同分母）','Location','southwest','FontSize',9);
text(130, 44, 'G_{do} = +39.7 dB', 'Color', cGray, 'FontSize', 9);
text(fsw/2*0.9, 62, 'f_{sw}/2 = 50k', 'Color', cRed, 'FontSize', 8.5, 'HorizontalAlignment','right');

subplot(2,1,2);
semilogx(f, rad2deg(phvd), 'Color', cBlue, 'LineWidth', 1.8); hold on;
semilogx(f, rad2deg(phvg), '--', 'Color', cGray, 'LineWidth', 1.4);
xline(438, ':', 'Color', cGray, 'LineWidth', 1);
xline(wz/(2*pi), ':', 'Color', cRed, 'LineWidth', 1.2);
xline(fsw/2, '--', 'Color', cRed, 'LineWidth', 1.2);
plot(f(i_fc), ph_fc, 'o', 'Color', cGreen, 'MarkerSize', 7, 'MarkerFaceColor', cGreen);
yline(-125, ':', 'Color', cGreen, 'LineWidth', 1);
text(160, -119, 'PM 55° 对应 ∠T = −125°', 'Color', cGreen, 'FontSize', 8.5);
text(2.5e4, -218, 'RHPZ 拖向 −270°（ESR 零点在 14.5k 处部分回收）', 'Color', cRed, 'FontSize', 8.5);
ylim([-270 20]); grid on; box on; set(gca,'FontSize',9.5);
xlabel('频率 (Hz)'); ylabel('相位 ∠G (度)','Interpreter','none');

set(fig,'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 9.2 6.6]);
print(fig,'-dpng','-r160','images/bode-boost-gvd.png');

fprintf('f0=%.0f Hz  Q=%.2f  frhpz=%.0f Hz  peak=%.1f dB  |G(1k)|=%.1f dB  ph(1k)=%.1f deg\n', ...
    w0/(2*pi), Q, wz/(2*pi), 20*log10(max(abs(Gvd))), mag_fc, ph_fc);
