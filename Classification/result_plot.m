
s1=0.5887;  std_s1=0.0181; 
s2=0.6575;  std_s2=0.0290; 
s3=0.6375;  std_s3=0.0317; 
s4=0.6775;  std_s4=0.0416;
s5=0.6125;  std_s5=0.0449; 
s6=0.5513;  std_s6=0.0451; 
s7=0.5975;  std_s7=0.0311; 
s8=0.6700;  std_s8=0.0409; 
s9=0.8387;  std_s9=0.0208; 
s10=0.5800;  std_s10=0.0675; 
s11=0.6787;  std_s11=0.0344; 

s1 = s1*100; s2 = s2*100; s3 = s3*100;s4 = s4*100; s5 = s5*100;
s6 = s6*100; s7 = s7*100; s8 = s8*100;
s9 = s9*100; s10 = s10*100; s11 = s11*100;

std_s1=std_s1*100;
std_s2=std_s2*100;
std_s3=std_s3*100;
std_s4=std_s4*100;
std_s5=std_s5*100;
std_s6=std_s6*100;
std_s7=std_s7*100;
std_s8=std_s8*100;
std_s9=std_s9*100;
std_s10=std_s10*100;
std_s11=std_s11*100;

%plot
figure('Color','white')
old = bar([s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11]);
hold on;
set(old,'FaceColor',1/255*[169 169 169]);
errorbar([s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11],[std_s1,std_s2,std_s3,std_s4,std_s5,std_s6,std_s7,std_s8,std_s9,std_s10,std_s11],'black.','linewidth',3);
xlabel({'\fontsize{18} \beta-    \alpha    \alpha\beta    \theta     \alpha     \eta      \theta    \beta+   \beta     \beta-   \alpha\beta','\fontsize{20}Older Adult Subject'}) % x-axis label

%text(3.6, -15, '\fontsize{20}Older Adult Subject')
ylabel('\fontsize{20}Classification Accuracy (%)') % y-axis label
ylim([0 100]);
%text(0.9,-9.3,'\beta-       \alpha       \alpha\beta      \theta        \alpha        \eta        \theta       \beta+      \beta        \beta-      \alpha\beta','fontsize',13,'color','r')

%title('\fontsize{20}Senior Classification Accuracy')
set(gca,'fontsize',20)

%std
senior=[s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11]';
x =std(senior)
y = mean(senior)

%% YOUNG
Young1= 0.8925*100; std_y1=0.0158*100 
%Young2=0.9933*100;  std_y2=0.0086*100 
Young3=0.8050*100;  std_y3=0.0237*100 
Young4=0.9950*100;  std_y4=0.0065*100 
Young5=0.5225*100;  std_y5=0.0227*100 
Young6=0.8650*100;  std_y6=0.0184*100 
Young7=0.9950*100;  std_y7=0.0065*100 
%Young8=0.9375*100;  std_y8=0.0144*100 
%Young9=0.9962*100;  std_y9=0.0084*100 
Young10=0.9450*100;  std_y10=0.0105*100 
Young11=0.7175*100;  std_y11=0.0188*100 
Young12=0.9750*100;  std_y12=0.0059*100 
Young13=0.7887*100;  std_y13=0.0297*100 
Young14=0.8763*100;  std_y14=0.0190*100 

%plot
figure('Color','white')
youngerSub = bar([Young1,Young3,Young4,Young5,Young6,Young7,Young10,Young11,Young12,Young13,Young14]);
hold on;
set(youngerSub,'FaceColor',1/255*[169 169 169]);
errorbar([Young1,Young3,Young4,Young5,Young6,Young7,Young10,Young11,Young12,Young13,Young14],[std_y1,std_y3,std_y4,std_y5,std_y6,std_y7,std_y10,std_y11,std_y12,std_y13,std_y14],'black.','linewidth',3);
xlabel({'\fontsize{18} \eta    \eta    \alpha+   \beta    \alpha+   \alpha+   \alpha+   \alpha\beta   \alpha+    \beta+   \eta','\fontsize{20}Younger Adult Subject'}) % x-axis label

ylabel('\fontsize{20}Classification Accuracy (%)') % y-axis label
ylim([0 100]);
%text(0.9,-9.3,'\eta        \eta        \alpha+      \beta       \alpha+      \alpha+      \alpha+     \alpha\beta      \alpha+     \beta+      \eta','fontsize',13,'color','r')
%title('\fontsize{20}Young Classification Accuracy')
set(gca,'fontsize',20)

%std
young=[Young1 Young3 Young4 Young5 Young6 Young7 Young10 Young11 Young12 Young13 Young14]';
x =std(young)
y = mean(young)

%% STATISTICS
h = ttest2(senior,young)

[h,p,ci,stats] = ttest2(senior, young)


%% AGE
Yage1=20; Yed1=16;
%Yage2=22; Yed2=15;
Yage3=21; Yed3=14;
Yage4=21; Yed4=13;
Yage5=19; Yed5=15;
Yage6=20; Yed6=13;
Yage7=21; Yed7=14;
%Yage8=21; Yed8=13;
%Yage9=24; Yed9=14;
Yage10=23; Yed10=14;
Yage11=22; Yed11=17;
Yage12=21; Yed12=13;
Yage13=19; Yed13=13;
Yage14=30; Yed14=23;
Yage = [Yage1 Yage3 Yage4 Yage5 Yage6 Yage7 Yage10 Yage11 Yage12 Yage13 Yage14];
Yed = [Yed1 Yed3 Yed4 Yed5 Yed6 Yed7 Yed10 Yed11 Yed12 Yed13 Yed14];

oage1=83; oed1=13;
oage2=76; oed2=13;
oage3=80; oed3=13;
oage4=73; oed4=12;
oage5=72; oed5=18;
oage6=70; oed6=18;
oage7=56; oed7=19;
oage8=80; oed8=20;
oage9=73; oed9=17;
oage10=62; oed10=16;
oage11=67; oed11=19;
oage = [oage1 oage2 oage3 oage4 oage5 oage6 oage7 oage8 oage9 oage10 oage11];
oed = [oed1 oed2 oed3 oed4 oed5 oed6 oed7 oed8 oed9 oed10 oed11];

[h,p,ci,stats] = ttest2(Yage, oage)
[h,p,ci,stats] = ttest2(Yed, oed)

