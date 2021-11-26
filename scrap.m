function T = scrap(app, url2)

url1 = 'https://www.ptt.cc/bbs/';
url3 = '/index.html';
url = [url1 url2 url3];
opts = weboptions('KeyName','Cookie','KeyValue','over18=1'); % 有的看板會先確認是否成年
try
    html = string(webread(url,opts));
    % 置底區分隔線"r-list-sep"以下不看
    html = extractBetween(html, '<html>', '<div class="r-list-sep"></div>');
    
    f = waitbar(0.2,'Please wait...');% 啟動提醒，進度 20%
    
    list_t = extractBetween(html, '<div class="title">', '</div>');
    list_t = flipud(list_t);
    
    list_title = repmat("",10000,1);
    list_href = repmat("",10000,1);
    
    % 標題 網址
    for i = 1:length(list_t)
        try
            list_title(i) = extractBetween(list_t(i), '">', '</a>');
            list_href(i) = extractBetween(list_t(i), '<a href="', '">');
        catch
            list_title(i) = "-";
            list_href(i) = "-";
        end
    end
    
    % 日期
    list_date = repmat("",10000,1);
    list_date_1 = extractBetween(html, '<div class="date">', '</div>');
    list_date_1 = flipud(list_date_1);
    list_date(1:length(list_date_1)) = list_date_1;
    
    % 作者
    list_author = repmat("",10000,1);
    list_author_1 = extractBetween(html, '<div class="author">', '</div>');
    list_author_1 = flipud(list_author_1);
    list_author(1:length(list_author_1)) = list_author_1;
    
    list_nrec = extractBetween(html, '<div class="nrec">', '</div>');
    list_nrec = flipud(list_nrec);
    list_n = zeros(10000,1);
    % 推數
    for i = 1:length(list_nrec)
        if contains(list_nrec(i), "爆")
            list_n(i) = 100;
        elseif contains(list_nrec(i), "X")
            list_n(i) = 0;
        elseif list_nrec(i) == ""
            list_n(i) = 0;
        else
            list_n(i) = extractBetween(list_nrec(i), '">', '</span>');
        end
    end
    n_count = length(list_nrec);
    
    waitbar(0.4,f,'熱門的看板可能會需要一些時間');% 提醒進度 40%
    % 若table的最後一個date = 第一個date則抓前頁網址 直到不是第一個date
    while list_date(1) == list_date_1(end)
        a = extractBetween(html, '<a class="btn wide" href="', '">');
        url = "https://www.ptt.cc" + a(2);
        opts = weboptions('KeyName','Cookie','KeyValue','over18=1'); % 有的看板會先確認是否成年
        html = string(webread(url,opts));
        
        list_t = extractBetween(html, '<div class="title">', '</div>');
        list_t = flipud(list_t);
        plus = length(list_title(list_title ~= ""));
        
        % 標題 網址
        for i = 1:length(list_t)
            try
                list_title(i+plus) = extractBetween(list_t(i), '">', '</a>');
                list_href(i+plus) = extractBetween(list_t(i), '<a href="', '">');
            catch
                list_title(i+plus) = "-";
                list_href(i+plus) = "-";
            end
        end
        
        % 日期
        list_date_1 = extractBetween(html, '<div class="date">', '</div>');
        list_date_1 = flipud(list_date_1);
        plus = length(list_date(list_date ~= ""));
        list_date(1+plus:length(list_date_1)+plus) = list_date_1;
        
        % 作者
        list_author_1 = extractBetween(html, '<div class="author">', '</div>');
        list_author_1 = flipud(list_author_1);
        plus = length(list_author(list_author ~= ""));
        list_author(1+plus:length(list_author_1)+plus) = list_author_1;
        
        list_nrec = extractBetween(html, '<div class="nrec">', '</div>');
        list_nrec = flipud(list_nrec);
        % 推數
        for i = 1:length(list_nrec)
            if contains(list_nrec(i), "爆")
                list_n(i+n_count) = 100;
            elseif contains(list_nrec(i), "X")
                list_n(i+n_count) = 0;
            elseif list_nrec(i) == ""
                list_n(i+n_count) = 0;
            else
                list_n(i+n_count) = extractBetween(list_nrec(i), '">', '</span>');
            end
        end
        n_count = n_count + length(list_nrec);
        
    end
    waitbar(1,f,'Finishing');% 最後提醒，進度 100%
    pause(1)
    T = table(list_title,list_date,list_author,list_n,list_href);
    Items={'title','date','author','n','href'};
    T.Properties.VariableNames = Items;
    
    timestr = string(datetime('now'));
    t = strsplit(timestr,'-');
    day = t(1);
    if (t(2) == "Jan")
        mon = " 1";end
    if (t(2) == "Feb")
        mon = " 2";end
    if (t(2) == "Mar")
        mon = " 3";end
    if (t(2) == "Apr")
        mon = " 4";end
    if (t(2) == "May")
        mon = " 5";end
    if (t(2) == "Jun")
        mon = " 6";end
    if (t(2) == "Jul")
        mon = " 7";end
    if (t(2) == "Aug")
        mon = " 8";end
    if (t(2) == "Sep")
        mon = " 9";end
    if (t(2) == "Oct")
        mon = "10";end
    if (t(2) == "Nov")
        mon = "11";end
    if (t(2) == "Dec")
        mon = "12";end
    
    T(T.date ~= strcat(mon,"/",day),:) = [];
    close(f)
    app.Button.Enable = 'on';
catch
    T = [];
    msgbox('無此看板')
end

end