classdef updatePosition < handle
  
  %properties
  properties 
    coord                  % Axes 0, 1, 2 representing X, Y, and Z positions
    numLamps;
    numFields;
    positionFields;       % EditField handle
    upperLimitLamp;             
    lowerLimitLamp;
    singleLamp;
    upperLimitValue;
    lowerLimitValue;
    underLimitColor;
    overLimitColor;

    A3200Handle; % A3200 connection handle;
    
    tm;                     %timer
    tmperiod;   %timer period;
    oldValue;
  end
  
  methods 
    % constructor
    function app = updatePosition(posFields, Axe, period, ...
            lamps, limits, limitColors)
      if nargin~=3 && nargin~=6
          error('updatePosition: Three, or Six inputs required.');
      end
      if Axe~=0 & Axe~=1 & Axe~=2
        error('input Axe should be number 0, 1, or 2 only.\n');
      end
      app.numFields=numel(posFields);
      app.positionFields=posFields;
      app.coord=Axe;
      app.tmperiod=period;
      app.oldValue=[];
      app.tm=timer('Period', app.tmperiod, 'ExecutionMode', 'fixedRate', ...
                  'TimerFcn', @app.updatePositionFcn, 'ErrorFcn', @app.errorFcn);
      if nargin==6
          app.numLamps=numel(lamps);
          if numel(lamps)==2
              app.upperLimitLamp=lamps{1};
              app.lowerLimitLamp=lamps{2};
          else
              app.singleLamp=lamps{1};
          end
              
          app.upperLimitValue=round(limits{1}*1.0e3)*1.0e-3;
          app.lowerLimitValue=round(limits{2}*1.0e3)*1.0e-3;
          app.overLimitColor=limitColors{1};
          app.underLimitColor=limitColors{2};
          
          %initialize lamps
          if app.numLamps==2
              app.upperLimitLamp.Color=app.underLimitColor;
              app.lowerLimitLamp.Color=app.underLimitColor;
          else
              app.singleLamp.Color=app.underLimitColor;
          end
      else
          app.numLamps=0;
      end
    end
  end
    
    
  methods 
    %callback functions
    function start(app)
      global RPAS_C
      if isempty(RPAS_C)
          RPAS_C=RPAS_Constants(parentDir(pwd));
      end
      if RPAS_C.A3200Available
          app.A3200Handle=A3200Connect;
      end

      app.oldValue=[];
      if isempty(app.tm)|| ~isvalid(app.tm)
          app.tm=timer('Period', app.tmperiod, 'ExecutionMode', 'fixedRate', ...
                  'TimerFcn', @app.updatePositionFcn, 'ErrorFcn', @app.errorFcn);
      end

      if strcmp(app.tm.Running, 'off')
        start(app.tm);
      end
      app.updatePositionFcn();
    end

    function updateLimitValue(app, upperLimit, lowerLimit)
        app.upperLimitValue=upperLimit;
        app.lowerLimitValue=lowerLimit;
    end
    
    function updatePositionFcn(app, tm, event)
      global RPAS_C
      if isempty(RPAS_C)
          RPAS_C=RPAS_Constants(parentDir(pwd));
      end
      if RPAS_C.A3200Available
          newValue=A3200StatusGetItem(app.A3200Handle, app.coord, ...
                  A3200StatusItem.PositionFeedback, 0);
      else
        % For simulation only, after test replace it with an error message
        global buffer;
        if isempty(buffer)
            buffer=[0 0 0; 0 0 0];
        end
        newValue=buffer(1, app.coord+1);
      end
      
      

      % update only at beginning or value changed
      newValue=round(newValue*1.0e6)*1.0e-6;
      if isempty(app.oldValue) | newValue~=app.oldValue
          if app.numFields>0
              for j=1:app.numFields
                  field=app.positionFields(j);
                  field.Value=newValue;
              end
          end
          if app.numLamps==2
              if newValue>app.upperLimitValue
                  app.upperLimitLamp.Color=app.overLimitColor;
              else
                  app.upperLimitLamp.Color=app.underLimitColor;
              end
              if newValue<app.lowerLimitValue
                  app.lowerLimitLamp.Color=app.overLimitColor;
              else
                app.lowerLimitLamp.Color=app.underLimitColor;
              end
          elseif app.numLamps==1
              if newValue>app.upperLimitValue||newValue<app.lowerLimitValue
                  app.singleLamp.Color=app.overLimitColor;
              else
                  app.singleLamp.Color=app.underLimitColor;
              end
          end
          app.oldValue=newValue;
          drawnow;
      end
    end
    
    function stop(app)
      global RPAS_C
      if isempty(RPAS_C)
          RPAS_C=RPAS_Constants(parentDir(pwd));
      end
        if ~isempty(app.tm) && strcmp(app.tm.Running, 'on')
            if isequal(get(app.tm, 'Running'),'on')
                app.tm.stop();
                delete(app.tm);
                app.tm=[];
                app.oldValue=[];
                app.updatePositionFcn();
            else
                delete(app.tm);
                app.tm=[];
            end
            if RPAS_C.A3200Available
                A3200Disconnect(app.A3200Handle);
            end
        end
    end
    
    function errorFcn(app, t, event)
        app.stop();
        msg=sprintf('Error happend to timer: %d. Stop.', app.coord);
        error(msg);
    end
  end
end
      
