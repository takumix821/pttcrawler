function Button_3Pushed(app, event)
url2 = app.EditField.Value;
app.url2_ = url2;
T = scrap(app, url2);
app.UITable.Data = T;
app.UITable.ColumnName = {'標題','日期','作者','推','網址'};
if height(T) > 0
    % 文章數
    app.Label_6.Text = num2str(size(T,1));
    % 爆文數
    b = 0;
    for i = 1:length(T.n)
        if T.n(i) == 100
            b = b+1;
        end
    end
    app.Label_7.Text = num2str(b);
end
end