% bode64.m — 6.4 节三条传函真实 Bode 图（Buck 数值：Vg=12,D=0.5,L=10u,C=100u,rC=20m,R=2）
clear; clc;

Vg = 12; D = 0.5; L = 10e-6; C = 100e-6; rC = 20e-3; R = 2; fsw = 500e3;

f  = logspace(2, 5.72, 1200).';          % 100 Hz ~ 525 kHz
w  = 2*pi*f;  s = 1j*w;

den = 1 + s*(L/R + rC*C) + s.^2*(L*C);
Gvd = Vg * (1 + s*rC*C) ./ den;          % 6.1
Gvg = D  * (1 + s*rC*C) ./ den;          % 6.2
% 6.3（修正版）：d̂=0、v̂g=0 时受控源短路 → 输出节点看到 R ∥ sL ∥ (rC+1/sC) 三条并联路径
Zout = R .* s*L .* (1 + s*rC*C) ./ (R + s*(L + R*rC*C) + s.^2*L*C*(R + rC));

f0  = 1/(2*pi*sqrt(L*C));
fz  = 1/(2*pi*rC*C);
fc  = 20e3;

cBlue=[24 95 165]/255; cGray=[110 108 102]/255; cGreen=[59 109 17]/255; cRed=[153 60 29]/255;

%% ---------- 图 1：Gvd 与 Gvg ----------
fig1 = figure('Visible','off','Position',[1 1 9.2 6.6],'Color','w');

subplot(2,1,1);
semilogx(f, 20*log10(abs(Gvd)), 'Color', cBlue, 'LineWidth', 1.8); hold on;
semilogx(f, 20*log10(abs(Gvg)), '--', 'Color', cGray, 'LineWidth', 1.5);
xline(f0, ':', 'Color', cGray, 'LineWidth', 1);
xline(fz, ':', 'Color', cGray, 'LineWidth', 1);
xline(fsw/2, '--', 'Color', cRed, 'LineWidth', 1.2);
i_fc = find(f>=fc,1);
plot(f(i_fc), 20*log10(abs(Gvd(i_fc))), 'o', 'Color', cGreen, 'MarkerSize', 7, 'MarkerFaceColor', cGreen);
text(f(i_fc)*1.06, 20*log10(abs(Gvd(i_fc)))+4.5, sprintf('20 kHz: %.1f dB', 20*log10(abs(Gvd(i_fc)))), 'Color', cGreen, 'FontSize', 9);
ylim([-70 45]); grid on; box on;
set(gca,'FontSize',9.5,'YAxisLocation','left');
ylabel('|G| (dB)');
title('Buck 功率级：G_{vd} 与 G_{vg}（按 6.1–6.2 公式计算）');
legend('G_{vd}（控制到输出）','G_{vg}（线到输出）','Location','southwest','FontSize',9);
text(f0*1.05, 40, sprintf('f_0 = %.1f kHz', f0/1e3), 'Color', cGray, 'FontSize', 8.5);
text(fz*1.05, 40, sprintf('f_{z,ESR} = %.0f kHz', fz/1e3), 'Color', cGray, 'FontSize', 8.5);
text(fsw/2*0.62, -62, 'f_{sw}/2 = 250 kHz', 'Color', cRed, 'FontSize', 8.5, 'HorizontalAlignment','right');

subplot(2,1,2);
semilogx(f, rad2deg(unwrap(angle(Gvd))), 'Color', cBlue, 'LineWidth', 1.8); hold on;
semilogx(f, rad2deg(unwrap(angle(Gvg))), '--', 'Color', cGray, 'LineWidth', 1.5);
xline(f0, ':', 'Color', cGray, 'LineWidth', 1);
xline(fz, ':', 'Color', cGray, 'LineWidth', 1);
xline(fsw/2, '--', 'Color', cRed, 'LineWidth', 1.2);
plot(f(i_fc), rad2deg(unwrap(angle(Gvd(i_fc)))), 'o', 'Color', cGreen, 'MarkerSize', 7, 'MarkerFaceColor', cGreen);
text(f(i_fc)*1.06, rad2deg(unwrap(angle(Gvd(i_fc))))-14, sprintf('%.0f°', rad2deg(unwrap(angle(Gvd(i_fc))))), 'Color', cGreen, 'FontSize', 9);
yline(-120, ':', 'Color', cGreen, 'LineWidth', 1);
text(150, -114, 'PM 60° 对应 ∠T = −120°', 'Color', cGreen, 'FontSize', 8.5);
ylim([-200 20]); grid on; box on; set(gca,'FontSize',9.5);
xlabel('频率 (Hz)'); ylabel('相位 ∠G (度)','Interpreter','none');

set(fig1,'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 9.2 6.6]);
print(fig1,'-dpng','-r160','images/bode-buck-gvd-gvg.png');

%% ---------- 图 2：Zout ----------
fig2 = figure('Visible','off','Position',[1 1 9.2 6.6],'Color','w');

subplot(2,1,1);
loglog(f, abs(Zout), 'Color', cBlue, 'LineWidth', 1.8); hold on;
xline(f0, ':', 'Color', cGray, 'LineWidth', 1);
xline(fsw/2, '--', 'Color', cRed, 'LineWidth', 1.2);
i_pk = find(abs(Zout)==max(abs(Zout)),1);
plot(f(i_pk), abs(Zout(i_pk)), 'o', 'Color', cRed, 'MarkerSize', 7, 'MarkerFaceColor', cRed);
text(f(i_pk)*1.2, abs(Zout(i_pk))*1.15, sprintf('并联谐振峰 ≈ %.1f Ω @ %.1f kHz', abs(Zout(i_pk)), f(i_pk)/1e3), 'Color', cRed, 'FontSize', 9);
text(115, 0.004, '低频 ≈ ωL（+20 dB/dec，DC→0）', 'Color', cGray, 'FontSize', 8.5);
text(2e4, 0.0035, '高频平台 ≈ r_C = 20 mΩ', 'Color', cGray, 'FontSize', 8.5);
ylim([1e-3 3]); grid on; box on; set(gca,'FontSize',9.5);
ylabel('|Z_{out}| (\Omega)');
title('Buck 开环输出阻抗 Z_{out}（R、sL、r_C+1/sC 三条支路并联，按 6.3 公式计算）');

subplot(2,1,2);
ph = rad2deg(unwrap(angle(Zout)));
semilogx(f, ph, 'Color', cBlue, 'LineWidth', 1.8); hold on;
xline(f0, ':', 'Color', cGray, 'LineWidth', 1);
xline(fsw/2, '--', 'Color', cRed, 'LineWidth', 1.2);
ylim([-120 120]); grid on; box on; set(gca,'FontSize',9.5);
xlabel('频率 (Hz)'); ylabel('相位 ∠Z_{out} (度)');
text(130, 62, '+90°（感性：ωL 主导）', 'Color', cGray, 'FontSize', 8.5);
text(3e4, -78, '−90°（容性：电容主导）', 'Color', cGray, 'FontSize', 8.5);

set(fig2,'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 9.2 6.6]);
print(fig2,'-dpng','-r160','images/bode-buck-zout.png');

%% ---------- 控制台核对关键数值 ----------
fprintf('f0=%.0f Hz  fz=%.0f Hz  |Gvd(20k)|=%.2f (%.1f dB)  phase=%.1f deg  Zpeak=%.2f Ohm @ %.0f Hz  Z(100Hz)=%.4f\n', ...
    f0, fz, abs(Gvd(i_fc)), 20*log10(abs(Gvd(i_fc))), rad2deg(unwrap(angle(Gvd(i_fc)))), ...
    abs(Zout(i_pk)), f(i_pk), abs(Zout(1)));
