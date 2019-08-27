labels = ["Myxoid","Mildly Myxoid","Sclerotic"];

groups = string(data{:,'Label_1'});
groups(groups == "M") = "Myxoid";
groups(groups == "MM") = "Mildly Myxoid";
groups(groups == "S") = "Sclerotic";

fontSize = 20;

xlimits = [0.25 1.75];

figure, boxplot(data{:,['MeanAlignment']},data{:,'Label_1'}), xticklabel(labels), title("Mean Alignment Metric")
set(gca,'FontSize',fontSize)

figure, boxplot(data{:,['MedianStandardDeviation']},data{:,'Label_1'}), xticlabels(labels), title("Median Standard Deviation Metric")
set(gca,'FontSize',fontSize)

figure, gscatter(x, data{:,'MedianStandardDeviation'}, categorical(groups), [], '.', 20), xlim(xlimits), title("Median Standard Deviation")
set(gca,'FontSize',fontSize)

figure, gscatter(x, data{:,'MeanAlignment'}, categorical(groups), [], '.', 20)), xlim(xlimits), title("Mean Alignment")
set(gca,'FontSize',fontSize)

figure, gscatter(data{:,['MedianStandardDeviation']}, data{:,['MeanAlignment']}, groups), xlabel("Median Standard Deviation"), ylabel("Mean Alignment")
set(gca,'FontSize',fontSize)

[~, pMvsS] = ttest2(M_medianStd,S_medianStd);
[~,pMMvsS] = ttest2(MM_medianStd,S_medianStd);
[~,pMvsMM] = ttest2(MM_medianStd,M_medianStd);