
maxGap = 10;  % M�ximo tama�o de brecha blanca
minSize = 100;  % Tama�o m�nimo de p�xeles
outputFolder = 'C:\\Users\\Luisbra\\Desktop\\funcional\\simulacion';
baseDir = 'C:\\Users\\Luisbra\\Desktop\\funcional\\simulacion';  % Definir baseDir aqu�

% Listado de subcarpetas dentro de baseDir
subfolders = {'Dogliotti2015', 'gons', 'gons740', 'mishra', 'moses3b', 'moses3b740', ...
            'ndci', 'ndvi', 'Nechad2009', 'Nechad2009ave', 'Nechad2010', ...
            'Nechad2010ave', 'Nechad2016', 'Novoa2017', 'oc22', 'oc33', ...
            'rgb', 'Rrs'};

for k = 1:length(subfolders)
    % Ruta completa de la subcarpeta
    saveAll = true;
    inputDir = fullfile(baseDir, subfolders{k});
    
    % Obtener la lista de im�genes en la subcarpeta
    imageFiles = dir(fullfile(inputDir, '*.png'));
    images = {imageFiles.name};

    % Procesar cada imagen en la subcarpeta
    for i = 1:length(images)
        % Leer la imagen actual
        imageFile = fullfile(inputDir, images{i});
        img = imread(imageFile);

        % Determinar el color de fondo seg�n el p�xel (1,1)
        backgroundColor = img(1, 1, :);

        % Separar el fondo del objeto
        isBackground = all(img == backgroundColor, 3);
        objectMask = ~isBackground;

        % Eliminar peque�os objetos no deseados (basados en tama�o)
        objectMask = bwareaopen(objectMask, minSize);

        % Rellenar huecos en los objetos hasta el tama�o maxGap
        objectMask = imclose(objectMask, strel('disk', maxGap));

        % Crear la imagen del objeto con transparencia
        objectImage = img .* uint8(objectMask);
        alphaChannel = uint8(objectMask) * 255;

        % Crear la imagen del fondo
        fondoImage = img;  % Copiar la imagen original
        fondoImage(repmat(~isBackground, [1, 1, 3])) = 0;  % Establecer los p�xeles de los objetos a negro (o transparentes si usas Alpha)

        % Guardar las im�genes resultantes con el mismo nombre en la carpeta de entrada
        [~, baseName, ext] = fileparts(images{i});
        areaOutputFile = fullfile(inputDir, [baseName, '_area.png']);
        fondoOutputFile = fullfile(inputDir, [baseName, '_fondo.png']);

        % Guardar la imagen con el �rea (sin fondo)
        imwrite(objectImage, areaOutputFile, 'Alpha', alphaChannel);

        % Guardar la imagen con el fondo
        imwrite(fondoImage, fondoOutputFile);
    end
end

disp('Proceso completado.');

        