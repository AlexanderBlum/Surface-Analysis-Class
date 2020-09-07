classdef SurfAnalysis < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Zscale {mustBeMember(Zscale,{'m','cm','mm', 'um', 'nm'})} = 'm'
        Xscale {mustBeMember(Xscale,{'m','cm','mm', 'um', 'nm'})} = 'm'
        dx
%         FilteredState
        Trace    double
        PhaseMap double
        Name     char
    end
    properties (Dependent)
        X     double
        XY    cell
        Nrows double
        Ncols double
    end
    
    methods
        function surfObj = SurfAnalysis(surfaceData, dx, Zscale, Xscale)
            % Construct an instance of this class
            if nargin == 4
                if (size(surfaceData, 1) == 1) || (size(surfaceData, 2) == 1)
                    surfObj.Trace = surfaceData;
                else
                    surfObj.PhaseMap = surfaceData;
                end
%                 [S.Ny, S.Nx] = size(surface_data);
%                 surfObj.FilteredState = 'unfiltered';
                surfObj.dx = dx;
                surfObj.Zscale = Zscale;
                surfObj.Xscale = Xscale;
            end
        end
        
        function Plot(surfObj)
            if ~isempty(surfObj.PhaseMap)
                XY = surfObj.XY; %#ok<*PROP>
                [XX,YY] = meshgrid(XY{1}, XY{2});
                surf(XX, YY, surfObj.PhaseMap,'LineStyle','none'); 
                view(0,90)
                axis([0, XY{1}(end), 0, XY{2}(end)]);
                ylabel(['Y (', surfObj.Xscale, ')']);
                xlabel(['X (', surfObj.Xscale, ')']);
                c = colorbar;
                c.Label.String = ['Z (', surfObj.Zscale, ')'];
                c.Label.FontSize = 12;
            elseif ~isempty(surfObj.Trace)                
                XX = surfObj.X;
                plot(XX, surfObj.Trace);
                ylabel(['Z (', surfObj.Zscale, ')']);
                xlabel(['X (', surfObj.Xscale, ')']);                
            end
        end       
        
        function avgSlice = GetAvgSlice(surfObj, dim)
        assert(~isempty(surfObj.PhaseMap),...
               'There is no PhaseMap in the object!');  
        if dim == "row"
            avgSlice = nanmean(surfObj.PhaseMap, 1);
        elseif dim == "col"
            avgSlice = nanmean(surfObj.PhaseMap, 2);
        end
        end
        
        function mapSlice = GetSlice(surfObj, ind, dim)
            mustBeNonempty(surfObj.PhaseMap);
            assert(isa(surfObj,'SurfAnalysis'),...
               'GetSlice Error:  Input obj is of class %s, not a SurfAnalysis object.',...
                class(surfObj));   
            if dim == "row"
                mapSlice = surfObj.PhaseMap(ind, :);
            elseif dim == "col"
                mapSlice = surfObj.PhaseMap(:, ind);
            end
        end                   
        
        function surfObj = RotateSurf(surfObj, rotAngle)
            surfObj.PhaseMap = imrotate(surfObj.PhaseMap, rotAngle, 'bilinear', 'crop');             
        end
            
        function InterpMap(surfObj, dxNew)
            mustBeNonempty(surfObj.PhaseMap);
            N = size(surfObj.PhaseMap, 1);
            xx = linspace(0, N*surfObj.dx, N);
            [XX, ~] = meshgrid(xx, xx);
            Ninterp = floor(xx(end)/dxNew); 
            xQ = linspace(0, Ninterp*dxNew, Ninterp);
            Xq = meshgrid(xQ, xQ);
            surfObj.PhaseMap = interp2(XX, XX', surfObj.PhaseMap, Xq, Xq', 'bilinear');
            surfObj.dx = dxNew;
        end % InterpMap
        
        function InterpTrace(surfObj, dxNew)
            mustBeNonempty(surfObj.Trace);
            N = length(surfObj.Trace);
            xx = linspace(0, N*surfObj.dx, N);
            Ninterp = floor(xx(end)/dxNew);
            xQ = linspace(0, Ninterp*dxNew, Ninterp);
            surfObj.Trace = interp1(xx, surfObj.Trace, xQ, 'linear');  
            surfObj.dx = dxNew;
        end % InterpTrace

        function fitPlane = FitPlane(surfObj)
            % replace surfObj.PhaseMap with Z
            [x, y] = meshgrid(1:1:size(surfObj.PhaseMap, 2),...
                              1:1:size(surfObj.PhaseMap, 1));
            XX = x(~isnan(surfObj.PhaseMap));
            YY = y(~isnan(surfObj.PhaseMap));
            ZZ = surfObj.PhaseMap(~isnan(surfObj.PhaseMap));
            A = [ones(size(XX)) XX YY]\ZZ; % model
%             A = [XX YY]\ZZ; % model            
%             fitPlane = x.*A(1) + y.*A(2);
            fitPlane = ones(size(surfObj.PhaseMap)).*A(1) + x.*A(2) + y.*A(3);            
        end        
        
        function Offset(obj, offsetVal)
            obj.Trace = obj.Trace + offsetVal;
        end
%% getter functions
        function Nrows = get.Nrows(surfObj)
            Nrows = size(surfObj.PhaseMap, 1);
        end
        
        function Ncols = get.Ncols(surfObj)
            Ncols = size(surfObj.PhaseMap, 2);
        end
        
        function X = get.X(surfObj)
            mustBeNonempty(surfObj.Trace);
            X = linspace(0, length(surfObj.Trace)*surfObj.dx, length(surfObj.Trace))';
        end
        
        function XY = get.XY(surfObj)
            mustBeNonempty(surfObj.PhaseMap);
            XY{1} = linspace(0, size(surfObj.PhaseMap, 1)*surfObj.dx, size(surfObj.PhaseMap, 1))';                
            XY{2} = linspace(0, size(surfObj.PhaseMap, 2)*surfObj.dx, size(surfObj.PhaseMap, 2))';
        end
        
%         function Ra = Ra(obj)
%         end
%         
%         function Rq = Rq(obj)
%         end
%         
%         function Rz = Rz(obj)
%         end
%
%         function STR(S)
%         end        
    end
end
