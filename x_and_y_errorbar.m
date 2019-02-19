function [veb,heb]=x_and_y_errorbar(x, y, x_error, y_error, symbol)
% x_and_y_errorbar - draws plot with both x and y error bars

marker_size=8;
kens_errorbar(x,y,x_error,y_error,symbol,marker_size);

veb=[];
heb=[];


% hold_state=ishold;
% [veb]=errorbar(x,y,y_error,symbol);
% hold on;
% [heb]=herrorbar(x,y,x_error,symbol);
% if (~hold_state)
%     hold off;
% end