%% WORKS for filling
%filling_between_lines = @(x,curve1,curve2,c) fill([x, fliplr(x)],[curve1, fliplr(curve2)],c);

figure('Color','white')
x = 1 : 2250;
curve1 = avgLeftC3 + typeOne15SE;
curve2 = avgLeftC3 - typeOne15SE;
plot(x, curve1, 'r');
hold on;
plot(x, curve2, 'r');
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, 'r');
set(h,'EdgeColor','none')


%% Plot Average Values With SE
figure('Color','white')
ax1 = subplot(1,2,1)
plot(ax1,avgLeftC3,'r')
title('Average ERD/S of Left Hand Tactile Stimulation')
xlabel('seconds') % x-axis label
ylabel('ERD/S') % y-axis label

hold on
plot(ax1,avgLeftC4,'r')
set(gca,'XTick',250:250:1750);
legend('Channel C3','Channel C4')
xlim([250 1750]);
set(gca,'XTickLabel',[-2 -1 0 1 2 3 4 5])

ax1 = subplot(1,2,2)
plot(ax1,avgRightC3,'r')
title('Average ERD/S of Right Hand Tactile Stimulation')
xlabel('seconds') % x-axis label
ylabel('ERD/S') % y-axis label
hold on
plot(ax1,avgRightC4,'c')
set(gca,'XTick',250:250:1750);
legend('Channel C3','Channel C4')
xlim([250 1750]);
savefig('Average Senior ERDS');
set(gca,'XTickLabel',[-2 -1 0 1 2 3 4 5])



%% start here
avgLeftC3 = avgLeftC3'; avgLeftC3=avgLeftC3*100;
avgLeftC4 = avgLeftC4'; avgLeftC4=avgLeftC4*100;

avgRightC3 = avgRightC3'; avgRightC3=avgRightC3*100;
avgRightC4 = avgRightC4'; avgRightC4=avgRightC4*100;

typeOne15SE = typeOne15SE'; typeOne15SE=typeOne15SE*100;
typeOne17SE = typeOne17SE'; typeOne17SE=typeOne17SE*100;
typeTwo15SE = typeTwo15SE'; typeTwo15SE=typeTwo15SE*100;
typeTwo17SE = typeTwo17SE'; typeTwo17SE=typeTwo17SE*100;

typeOne15SD=typeOne15SD'; typeOne15SD = typeOne15SD*100;
typeOne17SD=typeOne17SD'; typeOne17SD = typeOne17SD*100;
typeTwo15SD=typeTwo15SD'; typeTwo15SD = typeTwo15SD*100;
typeTwo17SD=typeTwo17SD'; typeTwo17SD = typeTwo17SD*100;


%% calculate t-test 

%calculate the average for every 100ms (25samples) and replace in matrix

freqSam = 50;
    tempLC3 = zeros(numSub,freqSam);tempLC4=zeros(numSub,freqSam);
    tempRC3 = zeros(numSub,freqSam);tempRC4=zeros(numSub,freqSam);
avgLC3=[];avgLC4=[];avgRC3=[];avgRC4=[];

for x =1:freqSam:2250
    tempLC3 = mean(LeftC3vertcat(:,x:x+freqSam-1),2);
    tempLC4 = mean(LeftC4vertcat(:,x:x+freqSam-1),2);
    tempRC3 = mean(RightC3vertcat(:,x:x+freqSam-1),2);
    tempRC4 = mean(RightC4vertcat(:,x:x+freqSam-1),2);

    %{
    %Replace the array w/ the average 
    for ind = 0:(freqSam-1)
        LeftC3vertcat(:,x+ind) = tempLC3(:,1);
        LeftC4vertcat(:,x+ind) = tempLC4(:,1);
        RightC3vertcat(:,x+ind)= tempRC3(:,1);
        RightC4vertcat(:,x+ind)= tempRC3(:,1);
    end
    %}
    
    avgLC3 = horzcat(avgLC3,tempLC3);
    avgLC4 = horzcat(avgLC4,tempLC4);
    avgRC3 = horzcat(avgRC3,tempRC3);
    avgRC4 = horzcat(avgRC4,tempRC4);
end

% calculate p value
[h,Leftp,ci,stats] = ttest2(avgLC3, avgLC4);
[h,Rightp,ci,stats] = ttest2(avgRC3, avgRC4);



%{
newLeftp=zeros(1,(2250/freqSam));
newRightp=zeros(1,(2250/freqSam));

counter = 1;
for y = 1:freqSam:2250
    newLeftp(1,counter)=Leftp(1,y);
    newRightp(1,counter)=Rightp(1,y);
    counter = counter+1;
end
%}

%{
figure
x = 1 :freqSam: 2250;
y2 = newLeftp;
yyaxis right
plot(x,y2)
hold on
set(gca,'XTick',250:250:2000);
legend([l1,l2],'Channel C3','Channel C4')
xlim([250 2000]);
set(gca,'XTickLabel',[-2 -1 0 1 2 3 4 5])
set(gca,'fontsize',20)
set(gcf,'color',[0.8 0.8 0.8]);
%}
%replacing anything nonsignificant w/ 0
%{
for i = 1:2250
    if Leftp(1,i)>(0.05/(2250/freqSam))
        Leftp(1,i) = 0;
    else Leftp(1,i) = 1;
    end
    
    if Rightp(1,i)>(0.05/(2250/freqSam))
        Rightp(1,i) = 0;
    else Rightp(1,i) = 1;
    end
end
%}

%% LEFT HAND
figure('Color','white')
x = 1 : 2250;
curve1 = avgLeftC3 + typeOne15SD;
curve2 = avgLeftC3 - typeOne15SD;
plot(x, curve1, 'Color',1/255*[209 41 41]);
hold on;
plot(x, curve2, 'r');
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, [1 0.5 0.5]);
set(h,'EdgeColor',1/255*[209 41 41],'LineWidth',1.4)
hold on
l1 = plot(avgLeftC3,'Color',1/255*[204 0 0],'LineStyle','--','LineWidth',1.4)
hold on 
for plotLeft = 1:(size(Leftp,2))
    if Leftp(plotLeft)<(0.05/(2250/freqSam))
        a = plotLeft*freqSam;
        d = -78:0.01:-76; %Younger Adults
        line([a a],[d(1) d(end)],'LineWidth',2,'Color',[0 0 0])
        hold on
        for l = 1:(freqSam-1)
            a = plotLeft*freqSam+l;
            line([a a],[d(1) d(end)],'LineWidth',2,'Color',[0 0 0])
            hold on
        end
    end
end

title('Left Vibro-tactile Continuous Stimulation')
xlabel('Time (s)') % x-axis label
ylabel('ERD/ERS%') % y-axis label

% plotting second line on first graph
hold on
curve1 = avgLeftC4 + typeOne17SD;
curve2 = avgLeftC4 - typeOne17SD;
plot(x, curve1, 'b');
hold on;
plot(x, curve2, 'b');
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
i = fill(x2, inBetween, 1/255*[122 167 255],'FaceAlpha',0.325);
set(i,'EdgeColor',1/255*[0 76 153],'LineWidth',1.4)
hold on
l2 = plot(avgLeftC4,'b','LineStyle','-.','Linewidth',1.4)


hold on
set(gca,'XTick',250:250:2000);
legend([l1,l2],'Channel C3','Channel C4')
xlim([250 2000]);
set(gca,'XTickLabel',[-2 -1 0 1 2 3 4 5])
set(gca,'fontsize',20)

% red line at 0 
hold on
yL = get(gca,'YLim');
line([750 750],yL,'Color','r','LineStyle',':');
ylim([-82 50])

%% RIGHT HAND
figure('Color','white')
x = 1 : 2250;
curve1 = avgRightC3 + typeTwo15SD;
curve2 = avgRightC3 - typeTwo15SD;
plot(x, curve1,'Color',1/255*[209 41 41]);
hold on;
plot(x, curve2, 'r');
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, [1 0.5 0.5]);
set(h,'EdgeColor',1/255*[209 41 41],'LineWidth',1.4)
hold on
l1 = plot(avgRightC3,'Color',1/255*[204 0 0],'LineStyle','--','LineWidth',1.4)
hold on 
for plotRight = 1:(size(Rightp,2))
    if Rightp(plotRight)<(0.05/(2250/freqSam))
        c = plotRight*freqSam;
        e = -78:0.01:-76;
        line([c c],[e(1) e(end)],'LineWidth',2,'Color',[0 0 0])
        hold on
        for g = 1:(freqSam-1)
            c = plotRight*freqSam+g;
            line([c c],[e(1) e(end)],'LineWidth',2,'Color',[0 0 0])
            hold on
        end
    end
end

title('Right Vibro-tactile Continuous Stimulation')
xlabel('Time (s)') % x-axis label
ylabel('ERD/ERS%') % y-axis label

% plotting second line on first graph
hold on
curve1 = avgRightC4 + typeTwo17SD;
curve2 = avgRightC4 - typeTwo17SD;
plot(x, curve1, 'b');
hold on;
plot(x, curve2, 'b');
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
i = fill(x2, inBetween, 1/255*[122 167 255],'FaceAlpha',0.325);
set(i,'EdgeColor',1/255*[0 76 153],'LineWidth',1.4)
hold on
l2 = plot(avgRightC4,'b','LineStyle','-.','Linewidth',1.4)


hold on
set(gca,'XTick',250:250:2000);
legend([l1,l2],'Channel C3','Channel C4')
xlim([250 2000]);
set(gca,'XTickLabel',[-2 -1 0 1 2 3 4 5])
set(gca,'fontsize',20)
% red line at 0 
hold on
yL = get(gca,'YLim');
line([750 750],yL,'Color','r','LineStyle',':');
ylim([-82 50])


