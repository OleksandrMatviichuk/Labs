classdef mainClass < handle
    properties 
        window = figure;
        playPauseBtn = uicontrol;
        stopBtn = uicontrol;
        alterationLabel = uicontrol;
        alterationField = uicontrol;
        noiseLabel = uicontrol;
        noiseTextField = uicontrol;
        plotingAxes = axes;
        plotingAnimatedLine;
        isPlaying = false;
        plotingIterator = 0;
    end
    
    methods 
        function self = mainClass()
           self.window.SizeChangedFcn = @self.resize;
           self.playPauseBtn.Parent = self.window;
           self.playPauseBtn.Units = 'pixels';
           self.playPauseBtn.String = '';
           playImage = imread('play.jpg');
           self.playPauseBtn.CData = imresize(playImage, [20 20]);
           self.playPauseBtn.Callback = @self.playPauseBthPressed;
           
           self.stopBtn.Parent = self.window;
           self.stopBtn.Units = 'pixels';
           self.stopBtn.String = '';
           playImage = imread('stop.jpg');
           self.stopBtn.CData = imresize(playImage, [20 20]);
           self.stopBtn.Callback = @self.stopBtnPressed;
           
           self.alterationLabel.Parent = self.window;
           self.alterationLabel.String = 'Рівень альтерації, мкВ';
           self.alterationLabel.Style = 'text';
           
           self.alterationField.Parent = self.window;
           self.alterationField.String = '200';
           self.alterationField.Style = 'edit';
           
           self.noiseLabel.Parent = self.window;
           self.noiseLabel.String = 'Рівень перешкоди, %';
           self.noiseLabel.Style = 'text';
           
           self.noiseTextField.Parent = self.window;
           self.noiseTextField.String = '15';
           self.noiseTextField.Style = 'edit';
           
           self.plotingAxes.Parent = self.window;
           self.plotingAxes.YMinorGrid = 'on';
           self.plotingAxes.XMinorGrid = 'on';
           xlim(self.plotingAxes, [0, 10]);
           ylim(self.plotingAxes, [-0.5, 2]);
           self.plotingAnimatedLine = animatedline('Parent', self.plotingAxes, 'Color', 'r');
           self.resize;
        end
        function resize(self,~,~)
           frame = self.window.Position;
           width = frame(3);
           height = frame(4);
           self.playPauseBtn.Position = [10, height - 30, 20, 20];
           self.stopBtn.Position = [30, height - 30, 20, 20];
           self.alterationLabel.Position = [50, height - 30, (width - 50)/4, 20];
           self.alterationField.Position = [(50 + (width - 50) / 4), height - 30, (width - 50) / 4, 20];
           self.noiseLabel.Position = [50 + ((width - 50) / 4) * 2, height - 30, (width - 50) / 4, 20];
           self.noiseTextField.Position = [50 + ((width - 50) / 4) * 3, height - 30, (width - 50) / 4, 20];
           self.plotingAxes.Position = [0, 0, 1, (height - 30) / height];
        end
        
        function playPauseBthPressed(self, ~, ~)
            if self.isPlaying 
                 playImage = imread('play.jpg');
                 self.playPauseBtn.CData = imresize(playImage, [20 20]);
                 self.isPlaying = false;
                 
            else
                 playImage = imread('pause.jpg');
                 self.playPauseBtn.CData = imresize(playImage, [20 20]);
                 self.isPlaying = true;
                 self.draw;
            end
        end
        
        function stopBtnPressed(self,~,~)
            clearpoints(self.plotingAnimatedLine);
            playImage = imread('play.jpg');
            self.playPauseBtn.CData = imresize(playImage, [20 20]);
            self.isPlaying = false;
            self.plotingIterator = 0;
        end
        
        function draw(self)
%           defaultDravigData
            a = [0.11, -0.11, 1.5, -0.18, 0, 0.8];
            tMax = [0.38, 0.478, 0.5, 0.523, 0, 0.7];
            b1 = [0.04, 0.01, 0.01, 0.015, 0, 0.06];
            b2 = [0.04, 0.01, 0.01, 0.015, 0, 0.06];
            t1 = tMax - 3 * b1;
            t2 = tMax + 3 * b2;
            tf6 = t1(6) + rand(1) * t1(6) * 0.1;
            ts6 = t2(6) + rand(1) * t2(6) * 0.1;
            maxTime = 10;
            maxPlotingPoints = 2500;
            time = linspace(0, maxTime, maxPlotingPoints);
            while self.isPlaying && (self.plotingIterator < maxPlotingPoints)            
                self.plotingIterator = self.plotingIterator + 1;
                x = time(self.plotingIterator);
                y = 0;

                for i = 1:6
                    amp = a(i);
                    tf = t1(i);
                    ts = t2(i);
                    tm = tMax(i);
%                   change time range
                     if i == 6
                          tf = tf6;
                          ts = ts6;
                          if floor(mod(x,2)) == 0
                              alteration = str2double(self.alterationField.String) / 1000;
                              amp = a(i) + alteration/a(i);
                          end
                     end
                     value = toothCalc(mod(x, 1), amp, tm, tf, ts);
%                    change alteration
                     if i == 3
                         value(value > amp * 0.05) = value(value > amp * 0.05) + rand(size(value(value > amp * 0.05))) * amp * 0.10; 
                     end
                      if i == 6
                          obstacle = str2double(self.noiseTextField.String) / 100;
                          value(value > amp * 0.05) = value(value > amp * 0.05) + rand(size(value(value > amp * 0.05))) * amp * obstacle;
                      end
                    y = y + value;
                end
                addpoints(self.plotingAnimatedLine, x, y);
                drawnow
            end
        end
    end
end