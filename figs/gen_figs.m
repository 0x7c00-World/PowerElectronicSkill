% 环路补偿设计文档配图生成脚本
% 输出 6 张 PNG 到 figs/ 目录，全部由传递函数数值计算得到
clear; close all;

out = 'C:\Users\heqingsong\Desktop\learning_project\PowerElectronicSkill\figs';
if ~exist(out,'dir'), mkdir(out); end

BLUE  = [0.094 0.373 0.647];   % #185FA5
RED   = [0.600 0.235 0.114];   % #993C1D
GREEN = [0.231 0.427 0.067];   % #3B6D11
GRAY  = [0.45 0.45 0.45];

set(groot,'defaultAxesFontSize',11);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultAxesGridAlpha',0.15);

s = tf('s');
deg = pi/180;
Vin0 = 12;

%% ================= 算例参数：12V -> 3.3V / 10A Buck =================
Rload = 3.3/10;            % 0.33 ohm
fsw   = 300e3;
L     = 4.7e-6;
C     = 940e-6;
rC    = 0.015;             % ESR
Ri    = 0.02;              % 电流检测
H     = 0.8/3.3;           % 反馈分压

% 电压模式对象（Fm=1/1V 锯齿）
Gvm = H*Vin0*(1+s*rC*C)/(1+s*(L/Rload + rC*C) + s^2*L*C);
% 电流模式对象（补偿器输出 -> 输出，含分压）
Gcm = H*(Rload/Ri)*(1+s*rC*C)/(1+s*Rload*C);

w = logspace(0,6.3,900);  f = w/(2*pi);
[mVM,pVM] = bode(Gvm,w); mVM=squeeze(mVM); pVM=squeeze(pVM);
[mCM,pCM] = bode(Gcm,w); mCM=squeeze(mCM); pCM=squeeze(pCM);

%% ---------- 图1：电压模式 vs 电流模式对象 Bode ----------
figure('Position',[60 60 880 640],'Color','w');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; hold on; grid on;
semilogx(f,20*log10(mVM),'-','Color',BLUE);
semilogx(f,20*log10(mCM),'--','Color',RED);
yline(0,':','Color',GRAY,'HandleVisibility','off');
ylabel('增益 (dB)');
legend({'电压模式：LC 双重极点，−40 dB/dec','电流模式：单极点，−20 dB/dec'},'Location','southwest');
title('同一台 Buck 的两种"性格"：被控对象 Bode 图','FontWeight','normal');
ax2 = nexttile; hold on; grid on;
semilogx(f,pVM,'-','Color',BLUE);
semilogx(f,pCM,'--','Color',RED);
yline(-180,':','Color',GRAY,'HandleVisibility','off');
yline(-90,':','Color',GRAY,'HandleVisibility','off');
ylabel('相位 (°)'); xlabel('频率 (Hz)');
legend({'电压模式：塌向 −180°','电流模式：ESR 零点把相位拉回'},'Location','southwest');
axs=findall(gcf,'Type','axes'); set(axs,'XScale','log');
exportgraphics(gcf, fullfile(out,'plant_bode.png'), 'Resolution',150);

%% ---------- 图2：RHPZ（Boost 对象，两种电感） ----------
D=0.5; Cb=470e-6; Vb=24;   % Vin=12 -> Vo=24，Rb 在下方设置
L1=100e-6; L2=33e-6;
rCb = 0.05; Rb = 5;
Gbz1 = (Vb/(1-D))*(1 - s*L1/((1-D)^2*Rb))*(1+s*rCb*Cb) / (1 + s*(L1/((1-D)^2*Rb)+rCb*Cb) + s^2*L1*Cb/(1-D)^2);
Gbz2 = (Vb/(1-D))*(1 - s*L2/((1-D)^2*Rb))*(1+s*rCb*Cb) / (1 + s*(L2/((1-D)^2*Rb)+rCb*Cb) + s^2*L2*Cb/(1-D)^2);
frz1 = (1-D)^2*Rb/L1/(2*pi);   % ~4.0 kHz
frz2 = (1-D)^2*Rb/L2/(2*pi);   % ~12.1 kHz
w2 = logspace(0,5,900); f2 = w2/(2*pi);
[mA,pA] = bode(Gbz1,w2); mA=squeeze(mA); pA=squeeze(pA); pA = pA - pA(1);
[mB,pB] = bode(Gbz2,w2); mB=squeeze(mB); pB=squeeze(pB); pB = pB - pB(1);

figure('Position',[60 60 880 640],'Color','w');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; hold on; grid on;
semilogx(f2,20*log10(mA),'-','Color',BLUE);
semilogx(f2,20*log10(mB),'--','Color',RED);
xline(frz1,':','Color',GREEN,'HandleVisibility','off');
xline(frz2,':','Color',GREEN,'HandleVisibility','off');
ymin1 = min(20*log10(mA)); ymax1 = max(20*log10(mA));
text(1.1e-1,26,sprintf('RHPZ %.1f kHz（L = 100 uH，绿虚线）',frz1/1e3),'Color',GREEN,'FontSize',10);
text(1.1e-1,19,sprintf('RHPZ %.1f kHz（L = 33 uH，绿虚线）',frz2/1e3),'Color',GREEN,'FontSize',10);
ylabel('增益 (dB)');
legend({'Boost，L = 100 \muH','Boost，L = 33 \muH'},'Location','southwest');
title('RHPZ：增益上升、相位滞后，减电感把它推高','FontWeight','normal');
ax2 = nexttile; hold on; grid on;
semilogx(f2,pA,'-','Color',BLUE);
semilogx(f2,pB,'--','Color',RED);
yline(-180,':','Color',GRAY,'HandleVisibility','off');
ylabel('相位 (°)'); xlabel('频率 (Hz)');
axs=findall(gcf,'Type','axes'); set(axs,'XScale','log');
exportgraphics(gcf, fullfile(out,'rhpz.png'), 'Resolution',150);

%% ================= Type II（电流模式算例，标准元件值复算） =================
fz2c = 8.56e3;  fp2c = 14.3e3;  K2 = 1.82e5;
Gc2 = K2*(1+s/(2*pi*fz2c))/(s*(1+s/(2*pi*fp2c)));
T   = Gc2*Gcm;
[Gm,Pm,Wcg,Wcp] = margin(T);
fc   = Wcp/(2*pi);
PmdB = 20*log10(Gm);

%% ================= Type III（同一功率级改电压模式） =================
[mV10,pV10] = bode(Gvm, 2*pi*1e4); mV10=squeeze(mV10); pV10=squeeze(pV10);
PMtarget = 60;
boost3 = PMtarget - 180 - pV10 + 90;          % 相对积分器需要的提升
k3 = tan(deg*(45 + boost3/4));                 % Type III: 双零/双极点重合对称放置
fz3 = 1e4/k3;  fp3 = 1e4*k3;
shape3 = (1+s/(2*pi*fz3))^2/(s*(1+s/(2*pi*fp3))^2);
K3 = (1/mV10)/abs(evalfr(shape3, 1i*2*pi*1e4));
Gc3 = K3*shape3;
T3  = Gc3*Gvm;
[Gm3,Pm3,~,Wcp3] = margin(T3);

%% ---------- 图3：Type II 与 Type III 补偿器 Bode ----------
w3 = logspace(-1,7,900); f3 = w3/(2*pi);
[mc2,pc2] = bode(Gc2,w3); mc2=squeeze(mc2); pc2=squeeze(pc2);
[mc3,pc3] = bode(Gc3,w3); mc3=squeeze(mc3); pc3=squeeze(pc3);

figure('Position',[60 60 880 640],'Color','w');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; hold on; grid on;
semilogx(f3,20*log10(mc2),'-','Color',BLUE);
semilogx(f3,20*log10(mc3),'--','Color',RED);
yline(0,':','Color',GRAY,'HandleVisibility','off');
[mgz,~]=bode(Gc2,2*pi*fz2c); [mgp,~]=bode(Gc2,2*pi*fp2c);
plot(fz2c,20*log10(mgz),'o','Color',BLUE,'MarkerFaceColor',BLUE,'MarkerSize',5);
plot(fp2c,20*log10(mgp),'o','Color',BLUE,'MarkerFaceColor',BLUE,'MarkerSize',5);
text(fz2c*0.30,44,sprintf('f_z=%.1f kHz',fz2c/1e3),'Color',BLUE,'FontSize',10);
text(fp2c*1.35,44,sprintf('f_p=%.1f kHz',fp2c/1e3),'Color',BLUE,'FontSize',10);
text(fz3*0.52,72,sprintf('f_z=%.1f kHz (×2)',fz3/1e3),'Color',RED,'FontSize',10);
text(fp3*1.6,22,sprintf('f_p=%.1f kHz (×2)',fp3/1e3),'Color',RED,'FontSize',10);
ylabel('增益 (dB)');
legend({'Type II（电流模式算例）','Type III（电压模式，双零点/双极点）'},'Location','southwest');
title('Type II / Type III 补偿器的 Bode 图（均含积分器）','FontWeight','normal');
ax2 = nexttile; hold on; grid on;
semilogx(f3,pc2,'-','Color',BLUE);
semilogx(f3,pc3,'--','Color',RED);
yline(0,':','Color',GRAY,'HandleVisibility','off');
yline(-90,':','Color',GRAY,'HandleVisibility','off');
ylabel('相位 (°)'); xlabel('频率 (Hz)');
text(1.5e1,-16,'提升 = 相位从 −90° 线抬升的量','Color',[0.35 0.35 0.35],'FontSize',10);
text(1.6e4,-63,'+15°','Color',BLUE,'FontSize',10,'FontWeight','bold');
text(1.7e4,2,'+102°','Color',RED,'FontSize',10,'FontWeight','bold');
axs=findall(gcf,'Type','axes'); set(axs,'XScale','log');
exportgraphics(gcf, fullfile(out,'type_comp.png'), 'Resolution',150);

%% ---------- 图4：算例环路增益裕度标注 ----------
[mT,pT] = bode(T,w); mT=squeeze(mT); pT=squeeze(pT);
figure('Position',[60 60 880 640],'Color','w');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; hold on; grid on;
semilogx(f,20*log10(mT),'-','Color',BLUE);
yline(0,'-','Color',GRAY);
xline(fc,':','Color',RED,'HandleVisibility','off');
plot(fc,0,'o','Color',RED,'MarkerFaceColor',RED,'MarkerSize',5);
text(fc*1.18,5,sprintf('f_c = %.2f kHz',fc/1e3),'Color',RED,'FontSize',10);
if isfinite(Wcg) && Wcg/(2*pi) < f(end)
    mAt = 20*log10(squeeze(bode(T,Wcg)));
    xline(Wcg/(2*pi),':','Color',GREEN,'HandleVisibility','off');
    plot(Wcg/(2*pi),mAt,'o','Color',GREEN,'MarkerFaceColor',GREEN,'MarkerSize',5);
    text(Wcg/(2*pi)*1.18,mAt+5,sprintf('GM = %.1f dB @ %.0f kHz',PmdB,Wcg/(2*pi)/1e3),'Color',GREEN,'FontSize',10);
end
ylabel('环路增益 |T| (dB)');
if isfinite(PmdB)
    ttl = sprintf('算例环路增益 T(s)：P_M = %.1f°，G_M = %.1f dB @ %.0f kHz，f_c = %.2f kHz',Pm,PmdB,Wcg/(2*pi)/1e3,fc/1e3);
else
    ttl = sprintf('算例环路增益 T(s)：P_M = %.1f°，f_c = %.2f kHz（简化模型相位不穿 −180°，G_M → ∞）',Pm,fc/1e3);
end
title(ttl,'FontWeight','normal');
ax2 = nexttile; hold on; grid on;
semilogx(f,pT,'-','Color',BLUE);
yline(-180,'-','Color',GRAY);
xline(fc,':','Color',RED,'HandleVisibility','off');
[~,phWcp] = bode(T,2*pi*fc); phWcp = squeeze(phWcp);
plot(fc,phWcp,'o','Color',RED,'MarkerFaceColor','w','MarkerSize',5);
text(fc*1.18,phWcp+9,sprintf('P_M = %.1f°',Pm),'Color',GREEN,'FontSize',10,'FontWeight','bold');
ylabel('环路相位 (°)'); xlabel('频率 (Hz)');
axs=findall(gcf,'Type','axes'); set(axs,'XScale','log');
exportgraphics(gcf, fullfile(out,'margins_cm.png'), 'Resolution',150);

%% ---------- 图5：补偿前后对比 ----------
figure('Position',[60 60 880 640],'Color','w');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; hold on; grid on;
semilogx(f,20*log10(mCM),'--','Color',RED);
semilogx(f,20*log10(mT),'-','Color',BLUE);
yline(0,'-','Color',GRAY);
xline(fc,':','Color',GREEN,'HandleVisibility','off');
plot(fc,0,'o','Color',GREEN,'MarkerFaceColor',GREEN,'MarkerSize',5);
text(fc*0.22,18,sprintf('f_c = %.2f kHz',fc/1e3),'Color',GREEN,'FontSize',10);
ylabel('增益 (dB)');
legend({'对象（补偿前）','环路增益（补偿后）：−20 dB/dec 穿越'},'Location','southwest');
title('补偿前 vs 补偿后：Type II 把 −11 dB 的对象抬成 0 dB 干净穿越','FontWeight','normal');
ax2 = nexttile; hold on; grid on;
semilogx(f,pCM,'--','Color',RED);
semilogx(f,pT,'-','Color',BLUE);
yline(-180,':','Color',GRAY,'HandleVisibility','off');
ylabel('相位 (°)'); xlabel('频率 (Hz)');
legend({'对象相位','环路相位（穿越处约 −121°，PM ≈ 59°）'},'Location','southwest');
axs=findall(gcf,'Type','axes'); set(axs,'XScale','log');
exportgraphics(gcf, fullfile(out,'before_after.png'), 'Resolution',150);

%% ---------- 图6：不同相位裕度的阶跃响应 ----------
PMs  = [30 45 60 76];
wn   = 2*pi*1e3;
tvec = 0:2e-5:2.5e-3;
figure('Position',[60 60 880 470],'Color','w'); hold on; grid on;
cols = {RED,[0.75 0.5 0.1],BLUE,GREEN};
for i=1:numel(PMs)
    z = PMs(i)/100;                      % 二阶近似：ζ ≈ PM/100（度）
    sys_cl = tf(wn^2,[1 2*z*wn wn^2]);
    [y,tt] = step(sys_cl,tvec);
    plot(tt,y,'-','Color',cols{i});
end
yline(1,':','Color',GRAY,'HandleVisibility','off');
xlabel('时间 (s)'); ylabel('归一化输出');
title('二阶近似下不同相位裕度的阶跃响应（\omega_n = 1 kHz）','FontWeight','normal');
legend({'PM = 30°：振铃明显','PM = 45°：轻微振铃','PM = 60°：甜点','PM = 76°：临界阻尼，偏迟钝'},'Location','northeast');
exportgraphics(gcf, fullfile(out,'step_pm.png'), 'Resolution',150);


%% ---------- 图7：通用裕度读法示例 ----------
% 教学用示例环路：积分器 + 单零点 + 三个极点（极点数 ≥3 相位才会真正穿过 −180°，
% 否则 GM 只是渐近无穷大，图上读不出 GM）
% Tg = 2e5·(1+s/wz) / [ s·(1+s/wp1)·(1+s/wp2)·(1+s/wp3) ]
Tg = 2e5*(1+s/(2*pi*1500))/(s*(1+s/(2*pi*500))*(1+s/(2*pi*3e4))*(1+s/(2*pi*5e4)));
[Gmg,Pmg,Wcgg,Wcpg] = margin(Tg);
fcg = Wcpg/(2*pi); w180g = Wcgg/(2*pi);
wg = logspace(0,6.5,900); fg = wg/(2*pi);
[mg_,pg_] = bode(Tg,wg); mg_=squeeze(mg_); pg_=squeeze(pg_);
[~,phWcp_] = bode(Tg,Wcpg); phWcp_ = squeeze(phWcp_);
[mg180,~] = bode(Tg,Wcgg); mg180 = squeeze(mg180);
GMg = -20*log10(mg180);

figure('Position',[60 60 880 640],'Color','w');
tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
ax1 = nexttile; hold on; grid on;
semilogx(fg,20*log10(mg_),'-','Color',BLUE);
yline(0,'-','Color',GRAY);
xline(fcg,':','Color',RED,'HandleVisibility','off');
xline(w180g,':','Color',GREEN,'HandleVisibility','off');
plot(fcg,0,'o','Color',RED,'MarkerFaceColor',RED,'MarkerSize',5);
plot(w180g,20*log10(mg180),'o','Color',GREEN,'MarkerFaceColor',GREEN,'MarkerSize',5);
text(fcg*1.12,12,sprintf('f_c = %.2f kHz（0 dB 穿越）',fcg/1e3),'Color',RED,'FontSize',10);
text(1.3e2,-56,{sprintf('相位穿 −180° 处：%.1f kHz，该处增益 %.1f dB',w180g/1e3,20*log10(mg180)),sprintf('→  G_M = %.1f dB',GMg)},'Color',GREEN,'FontSize',10);
ylabel('环路增益 |T| (dB)');
title('裕度的读法：PM 在 f_c 处读相位，GM 在相位穿 −180° 处读增益','FontWeight','normal');
ax2 = nexttile; hold on; grid on;
semilogx(fg,pg_,'-','Color',BLUE);
yline(-180,'-','Color',GRAY);
xline(fcg,':','Color',RED,'HandleVisibility','off');
xline(w180g,':','Color',GREEN,'HandleVisibility','off');
plot(fcg,phWcp_,'o','Color',RED,'MarkerFaceColor','w','MarkerSize',5);
text(fcg*0.55,phWcp_+16,sprintf('P_M = 180° - %.0f° = %.0f°',-phWcp_,Pmg),'Color',GREEN,'FontSize',10,'FontWeight','bold');
ylabel('环路相位 (°)'); xlabel('频率 (Hz)');
axs=findall(gcf,'Type','axes'); set(axs,'XScale','log');
exportgraphics(gcf, fullfile(out,'margins_generic.png'), 'Resolution',150);
fprintf('generic: fc=%.2f kHz PM=%.0f GM=%.0f dB w180=%.0f kHz\n',fcg/1e3,Pmg,GMg,w180g/1e3);

%% ---------- 控制台输出：供文档核对 ----------
fprintf('--- 电流模式 Type II 算例 ---\n');
[mgc10,ph10] = bode(Gcm,2*pi*1e4); ph10=squeeze(ph10);
fprintf('对象 @10kHz: %.2f dB / %.1f deg\n', 20*log10(squeeze(bode(Gcm,2*pi*1e4))), ph10);
fprintf('fc=%.2f kHz, PM=%.1f deg, GM=%.1f dB @ %.2f kHz\n', fc/1e3, Pm, PmdB, Wcg/(2*pi)/1e3);
fprintf('--- 电压模式 Type III 对照 ---\n');
fprintf('对象 @10kHz: %.2f dB / %.1f deg\n', 20*log10(mV10), pV10);
fprintf('boost=%.1f deg, k=%.2f, fz=%.2f kHz, fp=%.2f kHz, K=%.3g\n', boost3, k3, fz3/1e3, fp3/1e3, K3);
fprintf('fc=%.2f kHz, PM=%.1f deg, GM=%.1f dB\n', Wcp3/(2*pi)/1e3, Pm3, 20*log10(Gm3));
disp('done');
