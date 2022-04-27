classdef processRegister < handle
    properties (Access = private)

        timer;
        tmperiod;
        flag;

        handle;
    end

    properties (Access = public)
        container;
    end

    methods 

        function app = processRegister(handle, period)
            app.handle=handle;
            app.tmperiod=period;
            app.container=0;
            app.flag=false;
            app.timer=timer('Period', app.tmperiod, 'ExecutionMode', 'fixedRate', ...
                  'TimerFcn', @app.updateStatusFcn, 'ErrorFcn', @app.errorFcn);
        end

        function updateStatusFcn(app, tm, event )
            if app.container==0
                app.timer.stop();
                if isprop(app.handle, 'xupdater')
                    app.handle.stopTimer();
                end
                app.handle.init();
                if isprop(app.handle,'UIAxes')
                    cla(app.handle.UIAxes);
                end
            else
                %fprintf(1,'app: %s has process: %d\n', app.handle.UIFigure.Tag, app.container)
            end
        end

        function delete(app)
            delete(app.timer);
            delete(app);
        end
        
        function reset(app)
            app.container=0;
            app.Aborting(false);
            pause(app.tmperiod*2);
        end

        function addProcess(app)
            app.container=app.container+1;
            %fprintf(1,'addProcess: number of process running: %d\n', app.container)
        end

        function removeProcess(app)
            if app.container>0
                app.container=app.container-1;
            else
                app.container=0;
            end
            %fprintf(1,'removeProcess: number of process running: %d\n', app.container)
        end

        function Aborting(app, flag)
            app.flag=flag;
            if app.flag
                app.startTimer();
            else
                app.stopTimer();
            end
        end

        function flag=isAborting(app)
            if app.flag
                app.removeProcess();
                flag=true;
            else
                flag=false;
            end
        end

        function flag=abortingFinished(app)
            if app.container==0
                flag=true;
            else
                fprintf(1,'number of active process=%d\n', app.container);
                flag=false;
            end
        end

        function num=numberOfActiveProcess(app)
            num=app.container;
        end
    
        function startTimer(app)
            if isempty(app.timer)| ~isvalid(app.timer)
                app.timer =timer('Period', app.tmperiod, ...
                    'ExecutionMode', 'fixedRate', ...
                  'TimerFcn', @app.updateStatusFcn, ...
                  'ErrorFcn', @app.errorFcn);
            end
            if strcmp(get(app.timer, 'Running'),'on')
                % timer already start. Do nothing
            else
                start(app.timer);
            end
        end

        function stopTimer(app)
            if ~isempty(app.timer) & isvalid(app.timer)
                if strcmp(get(app.timer, 'Running'),'on')
                    app.timer.stop();
                    delete(app.timer);
                    app.timer=[];
                else
                    delete(app.timer);
                    app.timer=[];
                end
            end
        end

        

        function errorFcn(app, t, event)
            app.stopTimer();
            msg=sprintf('Error happend to timer: %d. Stop.', app.coord);
            error(msg);
        end
    end
end

