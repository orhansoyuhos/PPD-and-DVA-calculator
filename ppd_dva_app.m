function ppd_dva_app
% PPD/DVA Visual Calculator with Subject Position Offsets (Circle stimulus)
% ------------------------------------------------------------------------
%
% Run: ppd_dva_app_circle

% ---- Defaults ----
params.screenWidth_cm = 70;
params.screenXpixels  = 1920;
params.viewDist_cm    = 80;

params.eyeX_cm = 0;   % subject offset right (+) / left (-)
params.eyeY_cm = 0;   % subject offset up (+) / down (-)

params.fromMode = 'DVA (deg)';
params.value    = 3;      % interpreted by fromMode
params.roundN   = 2;

% ---- UI ----
fig = uifigure('Name','PPD & DVA Calculator', ...
    'Position',[80 80 1300 720]);

gl = uigridlayout(fig, [2 2]);
gl.RowHeight = {'1x', 190};
gl.ColumnWidth = {360, '1x'};
gl.Padding = [10 10 10 10];
gl.RowSpacing = 10;
gl.ColumnSpacing = 10;

% Controls (left)
pnl = uipanel(gl, 'Title', 'Inputs');
pnl.Layout.Row = 1; pnl.Layout.Column = 1;

ctrl = uigridlayout(pnl, [11 2]);
ctrl.RowHeight = {22,22,22,22,22,22,22,22,22,22,'1x'};
ctrl.ColumnWidth = {170, '1x'};
ctrl.Padding = [10 10 10 10];
ctrl.RowSpacing = 8;

% Plots (right)
plotPnl = uipanel(gl, 'Title', 'Visualization');
plotPnl.Layout.Row = 1; plotPnl.Layout.Column = 2;

pg = uigridlayout(plotPnl, [1 2]);
pg.ColumnWidth = {'1x','1x'};
pg.RowHeight = {'1x'};
pg.Padding = [10 10 10 10];
pg.ColumnSpacing = 10;

axSide  = uiaxes(pg); axSide.Layout.Column = 1;
axFront = uiaxes(pg); axFront.Layout.Column = 2;

% Output panel (bottom)
outPnl = uipanel(gl, 'Title', 'Computed Values & Formulas');
outPnl.Layout.Row = 2; outPnl.Layout.Column = [1 2];

out = uitextarea(outPnl, 'Editable','off', 'FontName','Consolas');
outPnl.SizeChangedFcn = @(~,~) resizeOut();
resizeOut();

% ---- Inputs ----
uilabel(ctrl, 'Text','Screen width (cm):');
nfW = uieditfield(ctrl, 'numeric', 'Value', params.screenWidth_cm, 'Limits',[5 500]);

uilabel(ctrl, 'Text','Screen X pixels:');
nfPx = uieditfield(ctrl, 'numeric', 'Value', params.screenXpixels, ...
    'RoundFractionalValues','on', 'Limits',[100 20000]);

uilabel(ctrl, 'Text','Viewing distance D (cm):');
nfD = uieditfield(ctrl, 'numeric', 'Value', params.viewDist_cm, 'Limits',[1 2000]);

uilabel(ctrl, 'Text','Convert from:');
ddFrom = uidropdown(ctrl, 'Items',{'DVA (deg)','Diameter (cm)','Diameter (px)'}, 'Value', params.fromMode);

uilabel(ctrl, 'Text','Value:');
nfVal = uieditfield(ctrl, 'numeric', 'Value', params.value, 'Limits',[0 1e9]);

uilabel(ctrl, 'Text','Subject offset X (cm):');
nfEyeX = uieditfield(ctrl, 'numeric', 'Value', params.eyeX_cm, 'Limits',[-500 500]);

uilabel(ctrl, 'Text','Subject offset Y (cm):');
nfEyeY = uieditfield(ctrl, 'numeric', 'Value', params.eyeY_cm, 'Limits',[-500 500]);

uilabel(ctrl, 'Text','Display rounding:');
nfRound = uieditfield(ctrl, 'numeric', 'Value', params.roundN, 'Limits',[0 10], 'RoundFractionalValues','on');

btn = uibutton(ctrl, 'Text','Reset defaults', 'ButtonPushedFcn', @(~,~) resetDefaults());
btn.Layout.Row = 10; btn.Layout.Column = [1 2];

% ---- Callbacks ----
nfW.ValueChangedFcn     = @(~,~) update();
nfPx.ValueChangedFcn    = @(~,~) update();
nfD.ValueChangedFcn     = @(~,~) update();
ddFrom.ValueChangedFcn  = @(~,~) update();
nfVal.ValueChangedFcn   = @(~,~) update();
nfEyeX.ValueChangedFcn  = @(~,~) update();
nfEyeY.ValueChangedFcn  = @(~,~) update();
nfRound.ValueChangedFcn = @(~,~) update();

% Initial render
update();

% ---- Nested helpers ----
    function resizeOut()
        out.Position = [10 10 outPnl.Position(3)-20 outPnl.Position(4)-35];
    end

    function resetDefaults()
        nfW.Value    = 70;
        nfPx.Value   = 1920;
        nfD.Value    = 80;
        ddFrom.Value = 'DVA (deg)';
        nfVal.Value  = 3;
        nfEyeX.Value = 0;
        nfEyeY.Value = 0;
        nfRound.Value = 2;
        update();
    end

    function update()
        % Inputs
        W    = nfW.Value;          % cm
        px   = nfPx.Value;         % pixels
        D    = nfD.Value;          % cm
        eyeX = nfEyeX.Value;       % cm
        eyeY = nfEyeY.Value;       % cm
        from = ddFrom.Value;
        v    = nfVal.Value;
        r    = nfRound.Value;

        % Pixel pitch (x)
        ppcm = px / W;             % px/cm
        cmPerPx = 1 / ppcm;        % cm/px

        % Eye + center
        E = [eyeX, eyeY, -D];
        C = [0, 0, 0];

        % Local ppd_x, ppd_y at screen center (1 px step around center)
        % Note: ppd_y assumes square pixels (cmPerPx applies to y too) unless you add screenHeight/screenYpixels.
        Pleft  = [-cmPerPx/2, 0, 0];
        Pright = [ +cmPerPx/2, 0, 0];
        ang1px_x = angleDeg(E, Pleft, Pright);
        ppd_x = 1 / ang1px_x;

        Pdown = [0, -cmPerPx/2, 0];
        Pup   = [0, +cmPerPx/2, 0];
        ang1px_y = angleDeg(E, Pdown, Pup);
        ppd_y = 1 / ang1px_y;

        % Convert circle diameter based on selection
        switch from
            case 'DVA (deg)'
                targetDeg = max(v, 0);
                diam_cm = solveDiameterForMeanDVA(E, C, targetDeg, D);
            case 'Diameter (cm)'
                diam_cm = max(v, 0);
            case 'Diameter (px)'
                diam_cm = max(v, 0) / ppcm;
        end

        diam_px = diam_cm * ppcm;

        % Angular diameters for that physical circle (centered at C)
        theta_x = dvaFromDiameter(E, C, diam_cm, 'x');
        theta_y = dvaFromDiameter(E, C, diam_cm, 'y');
        theta_mean = (theta_x + theta_y) / 2;

        % Reference distance eye->center
        distToCenter = norm(C - E);

        % Plots (side view uses condensed annotations)
        plotSide_compact(axSide, W, px, D, eyeX, eyeY, diam_cm, diam_px, theta_x, theta_y, theta_mean, ppd_x, ppd_y);
        plotFront(axFront, W, px, eyeX, eyeY, diam_cm);

        % Output
        out.Value = formatOutputs(W, px, D, eyeX, eyeY, ppcm, ppd_x, ppd_y, ...
            diam_cm, diam_px, theta_x, theta_y, theta_mean, distToCenter, r);
    end
end

% ---------------- Geometry utilities ----------------
function deg = angleDeg(E, P1, P2)
v1 = P1 - E;
v2 = P2 - E;
c = dot(v1,v2)/(norm(v1)*norm(v2));
c = max(-1,min(1,c));
deg = acosd(c);
end

function theta = dvaFromDiameter(E, C, diam_cm, axisChar)
half = diam_cm/2;
switch axisChar
    case 'x'
        P1 = C + [-half, 0, 0];
        P2 = C + [ +half, 0, 0];
    case 'y'
        P1 = C + [0, -half, 0];
        P2 = C + [0, +half, 0];
    otherwise
        error('axisChar must be ''x'' or ''y''.');
end
theta = angleDeg(E, P1, P2);
end

function diam_cm = solveDiameterForMeanDVA(E, C, targetDeg, D_onaxisGuess)
if targetDeg <= 0
    diam_cm = 0;
    return;
end

f = @(d) meanDVA(E, C, d) - targetDeg;

% On-axis guess: d ≈ 2*D*tan(theta/2)
d0 = 2*D_onaxisGuess*tand(targetDeg/2);

a = max(1e-9, d0*0.2);
b = max(1e-6, d0*2.0);

fa = f(a);
fb = f(b);

% Expand bracket until sign change
k = 0;
while sign(fa) == sign(fb) && k < 30
    b = b * 1.8;
    fb = f(b);
    k = k + 1;
    if b > 1e6
        break;
    end
end

if sign(fa) == sign(fb)
    % Fallback to approximation if bracketing fails
    diam_cm = d0;
    return;
end

diam_cm = fzero(f, [a b]);
end

function m = meanDVA(E, C, diam_cm)
tx = dvaFromDiameter(E, C, diam_cm, 'x');
ty = dvaFromDiameter(E, C, diam_cm, 'y');
m = (tx + ty) / 2;
end

% ---------------- Plotting ----------------
function plotSide_compact(ax, W_cm, screenXpixels, D_cm, eyeX, eyeY, diam_cm, diam_px, theta_x, theta_y, theta_mean, ppd_x, ppd_y)
% Compact side view: removes large annotation textbox to reduce clutter.

cla(ax); hold(ax,'on'); grid(ax,'on');

% Vertical cross-section (y vs z)
% Eye at (z=-D, y=eyeY), screen plane at z=0
eyePt = [-D_cm, eyeY];  % [z, y]
screenZ = 0;

halfD = diam_cm/2;

% Screen plane
planeH = max(18, min(70, max(diam_cm*2.2, 30)));
plot(ax, [screenZ screenZ], [-planeH/2 planeH/2], 'k-', 'LineWidth', 2);

% Eye
plot(ax, eyePt(1), eyePt(2), 'ko', 'MarkerFaceColor','k', 'MarkerSize', 6);
text(ax, eyePt(1), eyePt(2), '  Eye', 'FontWeight','bold', 'VerticalAlignment','middle', 'Clipping','on');

% Circle diameter in this cross-section (vertical diameter)
plot(ax, [screenZ screenZ], [-halfD halfD], 'b-', 'LineWidth', 4);

% Short label near top of diameter
text(ax, screenZ+0.6, halfD, sprintf('diam=%.0f px', diam_px), ...
    'Color','b', 'VerticalAlignment','bottom', 'FontWeight','bold', 'FontSize', 9, 'Clipping','on');

% Rays
plot(ax, [eyePt(1) screenZ], [eyePt(2) , +halfD], 'r-', 'LineWidth', 1.2);
plot(ax, [eyePt(1) screenZ], [eyePt(2) , -halfD], 'r-', 'LineWidth', 1.2);

% Viewing distance arrow (nominal D)
yArrow = -planeH/2 - 8;
plot(ax, [eyePt(1) screenZ], [yArrow yArrow], 'k-', 'LineWidth', 1);
plot(ax, [eyePt(1) eyePt(1)], [yArrow-1 yArrow+1], 'k-');
plot(ax, [screenZ screenZ], [yArrow-1 yArrow+1], 'k-');
text(ax, (eyePt(1)+screenZ)/2, yArrow-2, sprintf('D=%.1f cm', D_cm), ...
    'HorizontalAlignment','center', 'FontWeight','bold', 'FontSize', 9, 'Clipping','on');

% Title/axes
title(ax, 'Side view (compact)', 'FontWeight','bold');
xlabel(ax, 'Depth axis z (cm)');
ylabel(ax, 'Vertical axis y (cm)');

% Compact info block (bottom-left)
info = sprintf(['\\theta_x=%.2f°  \\theta_y=%.2f°  mean=%.2f°\n' ...
    'diam=%.2f cm (%.0f px)\n' ...
    'ppd_x=%.1f  ppd_y=%.1f\n' ...
    'Eye offsets: X=%.1f cm, Y=%.1f cm'], ...
    theta_x, theta_y, theta_mean, ...
    diam_cm, diam_px, ...
    ppd_x, ppd_y, ...
    eyeX, eyeY);

text(ax, 0.02, 0.02, info, ...
    'Units','normalized', ...
    'VerticalAlignment','bottom', ...
    'HorizontalAlignment','left', ...
    'FontName','Consolas', ...
    'FontSize', 8, ...
    'BackgroundColor','none', ...
    'Color',[0 0 0], ...
    'Clipping','on');

% Limits
xMin = -D_cm - 12; xMax = 12;
yLim = max(planeH/2 + 18, abs(eyeY) + abs(halfD) + 18);
axis(ax, [xMin xMax -yLim yLim]);
axis(ax, 'equal');

hold(ax,'off');
end

function plotFront(ax, W_cm, screenXpixels, eyeX, eyeY, diam_cm)
cla(ax); hold(ax,'on');

% Schematic height (unknown without screen height input)
H = max(25, W_cm * 0.6);

% Screen rectangle
rectangle(ax, 'Position',[0 0 W_cm H], 'EdgeColor','k', 'LineWidth',2);

% Screen center
cx = W_cm/2; cy = H/2;
plot(ax, cx, cy, 'k+', 'MarkerSize', 10, 'LineWidth', 2);
text(ax, cx+1, cy+1, 'Center', 'FontWeight','bold');

% Circle stimulus centered on screen center
r = diam_cm/2;
rectangle(ax, 'Position',[cx-r, cy-r, 2*r, 2*r], ...
    'Curvature',[1 1], 'FaceColor',[0.2 0.4 1.0], 'EdgeColor','none');

% Eye offset marker (schematic in same cm units)
ex = cx + eyeX;
ey = cy + eyeY;
plot(ax, ex, ey, 'ro', 'MarkerFaceColor','r', 'MarkerSize',6);
plot(ax, [cx ex], [cy ey], 'r-', 'LineWidth', 1.5);
text(ax, ex+1, ey, sprintf('Eye (%.1f, %.1f) cm', eyeX, eyeY), ...
    'Color','r', 'FontWeight','bold', 'VerticalAlignment','middle');

title(ax, 'Front view (schematic)', 'FontWeight','bold');
text(ax, W_cm/2, H+2, sprintf('Screen width = %.1f cm  (%d px)', W_cm, round(screenXpixels)), ...
    'HorizontalAlignment','center', 'FontWeight','bold');

axis(ax, [-5 W_cm+5 -5 H+12]);
axis(ax, 'off');
hold(ax,'off');
end

% ---------------- Output ----------------
function lines = formatOutputs(W, px, D, eyeX, eyeY, ppcm, ppd_x, ppd_y, diam_cm, diam_px, theta_x, theta_y, theta_mean, distToCenter, r)
fmt = @(x) num2str(round(x, r), ['%.' num2str(r) 'f']);

rad_cm = diam_cm/2;
rad_px = diam_px/2;

lines = {
    'CIRCLE STIMULUS (centered): parameters and results'
    ''
    'INPUTS'
    ['  screenWidth_cm        = ' fmt(W)]
    ['  screenXpixels         = ' num2str(round(px))]
    ['  viewing distance D    = ' fmt(D) ' cm']
    ['  subject offset X      = ' fmt(eyeX) ' cm']
    ['  subject offset Y      = ' fmt(eyeY) ' cm']
    ''
    'PIXEL PITCH'
    ['  ppcm                  = ' fmt(ppcm) ' px/cm']
    ''
    'LOCAL PPD AT SCREEN CENTER (OFF-AXIS ROBUST)'
    '  computed from the DVA subtended by a 1-pixel step at the center'
    ['  ppd_x (horizontal)    = ' fmt(ppd_x) ' px/deg']
    ['  ppd_y (vertical)      = ' fmt(ppd_y) ' px/deg']
    ['  distance eye->center  = ' fmt(distToCenter) ' cm (reference)']
    ''
    'CIRCLE ON SCREEN'
    ['  diameter              = ' fmt(diam_cm) ' cm   (' fmt(diam_px) ' px)']
    ['  radius                = ' fmt(rad_cm)  ' cm   (' fmt(rad_px)  ' px)']
    ''
    'ANGULAR DIAMETER (may differ X vs Y off-axis)'
    ['  theta_x               = ' fmt(theta_x) ' deg']
    ['  theta_y               = ' fmt(theta_y) ' deg']
    ['  theta_mean            = ' fmt(theta_mean) ' deg']
    ''
    'FORMULAS'
    '  ppcm = screenXpixels / screenWidth_cm'
    '  theta = acos( (v1·v2) / (|v1||v2|) ) * 180/pi'
    '  theta_x uses points (±diam/2, 0, 0) on the screen'
    '  theta_y uses points (0, ±diam/2, 0) on the screen'
    '  When converting from DVA, the app solves for theta_mean = requested DVA'
    ''
    'NOTE'
    '  ppd_y assumes square pixels unless you add screenHeight_cm and screenYpixels.'
    };
end
