﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

#Область ИзвлечениеТекста

// Добавляет и удаляет записи в регистр сведений ОчередьИзвлеченияТекста при изменении
// состояние извлечения текста версий файлов.
//
// Параметры:
//	ИсточникТекста - ОпределяемыйТип.ПрисоединенныйФайл - файл, у которого изменилось состояние извлечения текста.
//	СостояниеИзвлеченияТекста - ПеречислениеСсылка.СтатусыИзвлеченияТекстаФайлов - новый
//		статус извлечения текста у файла.
//
Процедура ОбновитьСостояниеОчередиИзвлеченияТекста(ИсточникТекста, СостояниеИзвлеченияТекста) Экспорт
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		Возврат;
	КонецЕсли;
	
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	
	УстановитьПривилегированныйРежим(Истина);
	
	НаборЗаписей = РегистрыСведений.ОчередьИзвлеченияТекста.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ОбластьДанныхВспомогательныеДанные.Установить(МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
	НаборЗаписей.Отбор.ИсточникТекста.Установить(ИсточникТекста);
	
	Если СостояниеИзвлеченияТекста = Перечисления.СтатусыИзвлеченияТекстаФайлов.НеИзвлечен
			ИЛИ СостояниеИзвлеченияТекста = Перечисления.СтатусыИзвлеченияТекстаФайлов.ПустаяСсылка() Тогда
			
		Запись = НаборЗаписей.Добавить();
		Запись.ОбластьДанныхВспомогательныеДанные = МодульРаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
		Запись.ИсточникТекста = ИсточникТекста.Ссылка;
			
	КонецЕсли;
		
	НаборЗаписей.Записать();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийПодсистемКонфигурации

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииПсевдонимовОбработчиков.
Процедура ПриОпределенииПсевдонимовОбработчиков(СоответствиеИменПсевдонимам) Экспорт
	
	СоответствиеИменПсевдонимам.Вставить("РаботаСФайламиСлужебный.ИзвлечьТекстИзФайлов");
	СоответствиеИменПсевдонимам.Вставить("РаботаСФайламиСлужебный.ОчиститьНенужныеФайлы");
	СоответствиеИменПсевдонимам.Вставить("РаботаСФайламиСлужебный.РегламентнаяСинхронизацияФайловWebdav");
	
КонецПроцедуры

// См. ОчередьЗаданийПереопределяемый.ПриОпределенииИспользованияРегламентныхЗаданий.
//
// Параметры:
//   ТаблицаИспользования - см. ОчередьЗаданийПереопределяемый.ПриОпределенииИспользованияРегламентныхЗаданий.ТаблицаИспользования
//
Процедура ПриОпределенииИспользованияРегламентныхЗаданий(ТаблицаИспользования) Экспорт
	
	НоваяСтрока = ТаблицаИспользования.Добавить();
	НоваяСтрока.РегламентноеЗадание = "ПланированиеИзвлеченияТекстаВМоделиСервиса";
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолнотекстовыйПоиск") Тогда
		МодульПолнотекстовыйПоискСервер = ОбщегоНазначения.ОбщийМодуль("ПолнотекстовыйПоискСервер");
		НоваяСтрока.Использование = МодульПолнотекстовыйПоискСервер.ИспользоватьПолнотекстовыйПоиск();
	Иначе
		НоваяСтрока.Использование = Ложь;
	КонецЕсли;
	
КонецПроцедуры

// См. ОчередьЗаданийПереопределяемый.ПриПолученииСпискаШаблонов.
//
// Параметры:
//   ШаблоныЗаданий - см. ОчередьЗаданийПереопределяемый.ПриПолученииСпискаШаблонов.ШаблоныЗаданий
//
Процедура ПриПолученииСпискаШаблонов(ШаблоныЗаданий) Экспорт
	
	ШаблоныЗаданий.Добавить("ОчисткаНенужныхФайлов");
	ШаблоныЗаданий.Добавить("СинхронизацияФайлов");
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки.
//
// Параметры:
//   Типы - см. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки.Типы
//
Процедура ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки(Типы) Экспорт
	
	Типы.Добавить(Метаданные.РегистрыСведений.ОчередьИзвлеченияТекста);
	
	ИсключаемыеТипы = ПрочитатьКэшВыгрузкиЗагрузкиФайловыхФункций().ОбъектыХранения;
	Для Каждого ИсключаемыйТип Из ИсключаемыеТипы Цикл
		Типы.Добавить(Метаданные.НайтиПоПолномуИмени(ИсключаемыйТип.Ключ));
	КонецЦикла;
	
КонецПроцедуры

// Вызывается при регистрации произвольных обработчиков выгрузки данных.
//
// Параметры:
//   ТаблицаОбработчиков - ТаблицаЗначений - в данной процедуре требуется
//  дополнить эту таблицу значений информацией о регистрируемых произвольных
//  обработчиках выгрузки данных. Колонки:
//    ОбъектМетаданных - ОбъектМетаданных, при выгрузке данных которого должен
//      вызываться регистрируемый обработчик,
//    Обработчик - ОбщийМодуль, общий модуль, в котором реализован произвольный
//      обработчик выгрузки данных. Набор экспортных процедур, которые должны
//      быть реализованы в обработчике, зависит от установки значений следующих
//      колонок таблицы значений,
//    Версия - Строка - номер версии интерфейса обработчиков выгрузки / загрузки данных,
//      поддерживаемого обработчиком,
//    ПередВыгрузкойТипа - Булево - флаг необходимости вызова обработчика перед
//      выгрузкой всех объектов информационной базы, относящихся к данному объекту
//      метаданных. Если присвоено значение Истина - в общем модуле обработчика должна
//      быть реализована экспортируемая процедура ПередВыгрузкойТипа(),
//      поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе выгрузи данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера,
//        Сериализатор - СериализаторXDTO, инициализированный с поддержкой выполнения
//          аннотации ссылок. В случае, если в произвольном обработчике выгрузки требуется
//          выполнять выгрузку дополнительных данных - следует использовать
//          СериализаторXDTO, переданный в процедуру ПередВыгрузкойТипа() в качестве
//          значения параметра Сериализатор, а не полученных с помощью свойства глобального
//          контекста СериализаторXDTO,
//        ОбъектМетаданных - ОбъектМетаданных, перед выгрузкой данных которого
//          был вызван обработчик,
//        Отказ - Булево - если в процедуре ПередВыгрузкойТипа() установить значение
//          данного параметра равным Истина - выгрузка объектов, соответствующих
//          текущему объекту метаданных, выполняться не будет.
//    ПередВыгрузкойОбъекта - Булево - флаг необходимости вызова обработчика перед
//      выгрузкой конкретного объекта информационной базы. Если присвоено значение
//      Истина - в общем модуле обработчика должна быть реализована экспортируемая процедура
//      ПередВыгрузкойОбъекта(), поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе выгрузи данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера,
//        МенеджерВыгрузкиОбъекта - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерВыгрузкиДанныхИнформационнойБазы -
//          менеджер выгрузки текущего объекта. Подробнее см. комментарий к программному интерфейсу обработки
//          ВыгрузкаЗагрузкаДанныхМенеджерВыгрузкиДанныхИнформационнойБазы. Параметр передается только при вызове
//          процедур обработчиков, для которых при регистрации указана версия не ниже 1.0.0.1,
//        Сериализатор - СериализаторXDTO, инициализированный с поддержкой выполнения
//          аннотации ссылок. В случае, если в произвольном обработчике выгрузки требуется
//          выполнять выгрузку дополнительных данных - следует использовать
//          СериализаторXDTO, переданный в процедуру ПередВыгрузкойОбъекта() в качестве
//          значения параметра Сериализатор, а не полученных с помощью свойства глобального
//          контекста СериализаторXDTO,
//        Объект - КонстантаМенеджерЗначения.*, СправочникОбъект.*, ДокументОбъект.*,
//          БизнесПроцессОбъект.*, ЗадачаОбъект.*, ПланСчетовОбъект.*, ПланОбменаОбъект.*,
//          ПланВидовХарактеристикОбъект.*, ПланВидовРасчетаОбъект.*, РегистрСведенийНаборЗаписей.*,
//          РегистрНакопленияНаборЗаписей.*, РегистрБухгалтерииНаборЗаписей.*,
//          РегистрРасчетаНаборЗаписей.*, ПоследовательностьНаборЗаписей.*, ПерерасчетНаборЗаписей.* -
//          объект данных информационной базы, перед выгрузкой которого был вызван обработчик.
//          Значение, переданное в процедуру ПередВыгрузкойОбъекта() в качестве значения параметра
//          Объект может быть модифицировано внутри обработчика ПередВыгрузкойОбъекта(), при
//          этом внесенные изменения будут отражены в сериализации объекта в файлах выгрузки, но
//          не будут зафиксированы в информационной базе
//        Артефакты - Массив Из ОбъектXDTO - набор дополнительной информации, логически неразрывно
//          связанной с объектом, но не являющейся его частью (артефакты объекта). Артефакты должны
//          сформированы внутри обработчика ПередВыгрузкойОбъекта() и добавлены в массив, переданный
//          в качестве значения параметра Артефакты. Каждый артефакт должен являться XDTO-объектом,
//          для типа которого в качестве базового типа используется абстрактный XDTO-тип
//          {http://www.1c.ru/1cFresh/Data/Dump/1.0.2.1}Artefact. Допускается использовать XDTO-пакеты,
//          помимо изначально поставляемых в составе подсистемы ВыгрузкаЗагрузкаДанных. В дальнейшем
//          артефакты, сформированные в процедуре ПередВыгрузкойОбъекта(), будут доступны в процедурах
//          обработчиков загрузки данных (см. комментарий к процедуре ПриРегистрацииОбработчиковЗагрузкиДанных().
//        Отказ - Булево - если в процедуре ПередВыгрузкойОбъекта() установить значение
//           данного параметра равным Истина - выгрузка объекта, для которого был вызван обработчик,
//           выполняться не будет.
//    ПослеВыгрузкиТипа() - Булево - флаг необходимости вызова обработчика после выгрузки всех
//      объектов информационной базы, относящихся к данному объекту метаданных. Если присвоено значение
//      Истина - в общем модуле обработчика должна быть реализована экспортируемая процедура
//      ПослеВыгрузкиТипа(), поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе выгрузи данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера,
//        Сериализатор - СериализаторXDTO, инициализированный с поддержкой выполнения
//          аннотации ссылок. В случае, если в произвольном обработчике выгрузки требуется
//          выполнять выгрузку дополнительных данных - следует использовать
//          СериализаторXDTO, переданный в процедуру ПослеВыгрузкиТипа() в качестве
//          значения параметра Сериализатор, а не полученных с помощью свойства глобального
//          контекста СериализаторXDTO,
//        ОбъектМетаданных - ОбъектМетаданных, после выгрузки данных которого
//          был вызван обработчик.
//
Процедура ПриРегистрацииОбработчиковВыгрузкиДанных(ТаблицаОбработчиков) Экспорт
	
	СправочникиФайлов = ПрочитатьКэшВыгрузкиЗагрузкиФайловыхФункций().СправочникиФайлов;
	Для Каждого СправочникФайлов Из СправочникиФайлов Цикл
		
		НовыйОбработчик = ТаблицаОбработчиков.Добавить();
		НовыйОбработчик.ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(СправочникФайлов.Ключ);
		НовыйОбработчик.Обработчик = РаботаСФайламиСлужебныйВМоделиСервиса;
		НовыйОбработчик.ПередВыгрузкойОбъекта = Истина;
		НовыйОбработчик.Версия = "1.0.0.1";
		
	КонецЦикла;
	
	НовыйОбработчик = ТаблицаОбработчиков.Добавить();
	НовыйОбработчик.ОбъектМетаданных = Метаданные.Справочники.Файлы;
	НовыйОбработчик.Обработчик = РаботаСФайламиСлужебныйВМоделиСервиса;
	НовыйОбработчик.ПередВыгрузкойОбъекта = Истина;
	НовыйОбработчик.Версия = "1.0.0.1";
	
КонецПроцедуры

// Вызывается при регистрации произвольных обработчиков загрузки данных.
//
// Параметры:
//   ТаблицаОбработчиков - ТаблицаЗначений - в данной процедуре требуется
//  дополнить эту таблицу значений информацией о регистрируемых произвольных
//  обработчиках загрузки данных. Колонки:
//    ОбъектМетаданных - ОбъектМетаданных, при загрузке данных которого должен
//      вызываться регистрируемый обработчик,
//    Обработчик - ОбщийМодуль, общий модуль, в котором реализован произвольный
//      обработчик загрузки данных. Набор экспортных процедур, которые должны
//      быть реализованы в обработчике, зависит от установки значений следующих
//      колонок таблицы значений,
//    Версия - Строка - номер версии интерфейса обработчиков выгрузки / загрузки данных,
//      поддерживаемого обработчиком,
//    ПередСопоставлениемСсылок - Булево - флаг необходимости вызова обработчика перед
//      сопоставлением ссылок (в исходной ИБ и в текущей), относящихся к данному объекту
//      метаданных. Если присвоено значение Истина - в общем модуле обработчика должна
//      быть реализована экспортируемая процедура ПередСопоставлениемСсылок(),
//      поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе загрузки данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.
//        ОбъектМетаданных - ОбъектМетаданных, перед сопоставлением ссылок которого
//          был вызван обработчик,
//        СтандартнаяОбработка - Булево - если процедуре ПередСопоставлениемСсылок()
//          установить значение данного параметра равным Ложь, вместо стандартного
//          сопоставления ссылок (поиск объектов в текущей ИБ с теми же значениями
//          естественного ключа, которые были выгружены из ИБ-источника) будет
//          вызвана функция СопоставитьСсылки() общего модуля, в процедуре
//          ПередСопоставлениемСсылок() которого значение параметра СтандартнаяОбработка
//          было установлено равным Ложь.
//          Параметры функции СопоставитьСсылки():
//            Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//              контейнера, используемый в процессе загрузки данных. Подробнее см. комментарий
//              к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера,
//            ТаблицаИсходныхСсылок - ТаблицаЗначений - содержащая информацию о ссылках,
//              выгруженных из исходной ИБ. Колонки:
//                ИсходнаяСсылка - ЛюбаяСсылка, ссылка объекта исходной ИБ, которую требуется
//                  сопоставить c ссылкой в текущей ИБ,
//                Остальные колонки равным полям естественного ключа объекта, которые в
//                  процессе выгрузки данных были переданы в функцию
//                  Обработка.ВыгрузкаЗагрузкаДанныхМенеджерВыгрузкиДанныхИнформационнойБазы.ТребуетсяСопоставитьСсылкуПриЗагрузке()
//          Возвращаемое значение функции СопоставитьСсылки() - ТаблицаЗначений, колонки:
//            ИсходнаяСсылка - ЛюбаяСсылка, ссылка объекта, выгруженная из исходной ИБ,
//            Ссылка - ЛюбаяСсылка, сопоставленная исходной ссылка в текущей ИБ.
//        Отказ - Булево - если в процедуре ПередСопоставлениемСсылок() установить значение
//          данного параметра равным Истина - сопоставление ссылок, соответствующих
//          текущему объекту метаданных, выполняться не будет.
//    ПередЗагрузкойТипа - Булево - флаг необходимости вызова обработчика перед
//      загрузкой всех объектов данных, относящихся к данному объекту
//      метаданных. Если присвоено значение Истина - в общем модуле обработчика должна
//      быть реализована экспортируемая процедура ПередЗагрузкойТипа(),
//      поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе загрузки данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.
//        ОбъектМетаданных - ОбъектМетаданных, перед загрузкой всех данных которого
//          был вызван обработчик,
//        Отказ - Булево - если в процедуре ПередЗагрузкойТипа() установить значение данного
//          параметра равным Истина - загрузка всех объектов данных соответствующих текущему
//          объекту метаданных выполняться не будет.
//    ПередЗагрузкойОбъекта - Булево - флаг необходимости вызова обработчика перед
//      загрузкой объекта данных, относящихся к данному объекту
//      метаданных. Если присвоено значение Истина - в общем модуле обработчика должна
//      быть реализована экспортируемая процедура ПередЗагрузкойОбъекта(),
//      поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе загрузки данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.
//        Объект - КонстантаМенеджерЗначения.*, СправочникОбъект.*, ДокументОбъект.*,
//          БизнесПроцессОбъект.*, ЗадачаОбъект.*, ПланСчетовОбъект.*, ПланОбменаОбъект.*,
//          ПланВидовХарактеристикОбъект.*, ПланВидовРасчетаОбъект.*, РегистрСведенийНаборЗаписей.*,
//          РегистрНакопленияНаборЗаписей.*, РегистрБухгалтерииНаборЗаписей.*,
//          РегистрРасчетаНаборЗаписей.*, ПоследовательностьНаборЗаписей.*, ПерерасчетНаборЗаписей.* -
//          объект данных информационной базы, перед загрузкой которого был вызван обработчик.
//          Значение, переданное в процедуру ПередЗагрузкойОбъекта() в качестве значения параметра
//          Объект может быть модифицировано внутри процедуры обработчика ПередЗагрузкойОбъекта().
//        Артефакты - Массив Из ОбъектXDTO - дополнительные данные, логически неразрывно связанные
//          с объектом данных, но не являющиеся его частью. Сформированы в экспортируемых процедурах
//          ПередВыгрузкойОбъекта() обработчиков выгрузки данных (см. комментарий к процедуре
//          ПриРегистрацииОбработчиковВыгрузкиДанных(). Каждый артефакт должен являться XDTO-объектом,
//          для типа которого в качестве базового типа используется абстрактный XDTO-тип
//          {http://www.1c.ru/1cFresh/Data/Dump/1.0.2.1}Artefact. Допускается использовать XDTO-пакеты,
//          помимо изначально поставляемых в составе подсистемы ВыгрузкаЗагрузкаДанных.
//        Отказ - Булево - если в процедуре ПередЗагрузкойОбъекта() установить значение данного
//          параметра равным Истина - загрузка объекта данных выполняться не будет.
//    ПослеЗагрузкиОбъекта - Булево - флаг необходимости вызова обработчика после
//      загрузки объекта данных, относящихся к данному объекту
//      метаданных. Если присвоено значение Истина - в общем модуле обработчика должна
//      быть реализована экспортируемая процедура ПослеЗагрузкиОбъекта(),
//      поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе загрузки данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.
//        Объект - КонстантаМенеджерЗначения.*, СправочникОбъект.*, ДокументОбъект.*,
//          БизнесПроцессОбъект.*, ЗадачаОбъект.*, ПланСчетовОбъект.*, ПланОбменаОбъект.*,
//          ПланВидовХарактеристикОбъект.*, ПланВидовРасчетаОбъект.*, РегистрСведенийНаборЗаписей.*,
//          РегистрНакопленияНаборЗаписей.*, РегистрБухгалтерииНаборЗаписей.*,
//          РегистрРасчетаНаборЗаписей.*, ПоследовательностьНаборЗаписей.*, ПерерасчетНаборЗаписей.* -
//          объект данных информационной базы, после загрузки которого был вызван обработчик.
//        Артефакты - Массив Из ОбъектXDTO - дополнительные данные, логически неразрывно связанные
//          с объектом данных, но не являющиеся его частью. Сформированы в экспортируемых процедурах
//          ПередВыгрузкойОбъекта() обработчиков выгрузки данных (см. комментарий к процедуре
//          ПриРегистрацииОбработчиковВыгрузкиДанных(). Каждый артефакт должен являться XDTO-объектом,
//          для типа которого в качестве базового типа используется абстрактный XDTO-тип
//          {http://www.1c.ru/1cFresh/Data/Dump/1.0.2.1}Artefact. Допускается использовать XDTO-пакеты,
//          помимо изначально поставляемых в составе подсистемы ВыгрузкаЗагрузкаДанных.
//    ПослеЗагрузкиТипа - Булево - флаг необходимости вызова обработчика после
//      загрузки всех объектов данных, относящихся к данному объекту
//      метаданных. Если присвоено значение Истина - в общем модуле обработчика должна
//      быть реализована экспортируемая процедура ПослеЗагрузкиТипа(),
//      поддерживающая следующие параметры:
//        Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//          контейнера, используемый в процессе загрузки данных. Подробнее см. комментарий
//          к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.
//        ОбъектМетаданных - ОбъектМетаданных, после загрузки всех объектов которого
//          был вызван обработчик.
//
Процедура ПриРегистрацииОбработчиковЗагрузкиДанных(ТаблицаОбработчиков) Экспорт
	
	СправочникиФайлов = ПрочитатьКэшВыгрузкиЗагрузкиФайловыхФункций().СправочникиФайлов;
	Для Каждого СправочникФайлов Из СправочникиФайлов Цикл
		
		НовыйОбработчик = ТаблицаОбработчиков.Добавить();
		НовыйОбработчик.ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(СправочникФайлов.Ключ);
		НовыйОбработчик.Обработчик = РаботаСФайламиСлужебныйВМоделиСервиса;
		НовыйОбработчик.ПередЗагрузкойОбъекта = Истина;
		НовыйОбработчик.Версия = "1.0.0.1";
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

// АПК:299-выкл - обработчики событий и обновления ИБ.
#Область ОбработчикиВыгрузкиДанных

// Параметры:
//   Артефакты - Массив
//
Процедура ПередВыгрузкойОбъекта(Контейнер, МенеджерВыгрузкиОбъекта, Сериализатор, Объект, Артефакты, Отказ) Экспорт
	
	Если ТипЗнч(Объект) = Тип("СправочникОбъект.Файлы") Тогда
		ОчиститьСсылкаНаТомХраненияФайлов(Объект);
		Возврат;
	КонецЕсли;
	
	СправочникиФайлов = ПрочитатьКэшВыгрузкиЗагрузкиФайловыхФункций().СправочникиФайлов;
	
	Обработчик = СправочникиФайлов.Получить(Объект.Метаданные().ПолноеИмя());
	
	Если Обработчик = Неопределено Тогда
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Объект метаданных %1 не может быть обработан обработчиком
				|РаботаСФайламиСлужебныйВМоделиСервиса.ПередВыгрузкойОбъекта().'",
				ОбщегоНазначения.КодОсновногоЯзыка()),
			Объект.Метаданные().ПолноеИмя());
		
	КонецЕсли;
	
	МодульОбработчика = ОбщегоНазначения.ОбщийМодуль(Обработчик);
	РасширениеФайла = МодульОбработчика.РасширениеФайла(Объект);
	ИмяФайла = Контейнер.СоздатьПроизвольныйФайл(РасширениеФайла);
	
	Попытка
		
		МодульОбработчика.ВыгрузитьФайл(Объект, ИмяФайла);
		
		Артефакт = ФабрикаXDTO.Создать(ТипАртефактФайла());
		Артефакт.RelativeFilePath = Контейнер.ПолучитьОтносительноеИмяФайла(ИмяФайла);
		Артефакты.Добавить(Артефакт);
		
	Исключение
		
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		
		Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		
			МодульТехнологияСервиса = ОбщегоНазначения.ОбщийМодуль("ТехнологияСервиса");
			Если ОбщегоНазначенияКлиентСервер.СравнитьВерсии(МодульТехнологияСервиса.ВерсияБиблиотеки(), "2.0.2.15") >= 0 Тогда
				Предупреждение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Выгрузка файла %1 (тип %2) пропущена по причине
					|%3'"),
					Объект,
					Объект.Метаданные().ПолноеИмя(),
					КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
				
				Контейнер.ДобавитьПредупреждение(Предупреждение);
			КонецЕсли;
			
		КонецЕсли;
		
		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Файлы.Выгрузка данных для перехода в сервис'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка,
			Объект.Метаданные(),
			Объект.Ссылка,
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
			
		Контейнер.ИсключитьФайл(ИмяФайла);
		
	КонецПопытки;
	
	ОчиститьСсылкаНаТомХраненияФайлов(Объект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиЗагрузкиДанных

Процедура ПередЗагрузкойОбъекта(Контейнер, Объект, Артефакты, Отказ) Экспорт
	
	СправочникиФайлов = ПрочитатьКэшВыгрузкиЗагрузкиФайловыхФункций().СправочникиФайлов;
	
	Обработчик = СправочникиФайлов.Получить(Объект.Метаданные().ПолноеИмя());
	
	Если Обработчик = Неопределено Тогда
		
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Объект метаданных %1 не может быть обработан обработчиком
				|РаботаСФайламиСлужебныйВМоделиСервиса.ПередВыгрузкойОбъекта().'", ОбщегоНазначения.КодОсновногоЯзыка()),
			Объект.Метаданные().ПолноеИмя());
		
	КонецЕсли;
	
	МодульОбработчика = ОбщегоНазначения.ОбщийМодуль(Обработчик);
	
	Для Каждого Артефакт Из Артефакты Цикл
		
		Если Артефакт.Тип() = ТипАртефактФайла() Тогда
			
			МодульОбработчика.ЗагрузитьФайл(Объект, Контейнер.ПолучитьПолноеИмяФайла(Артефакт.RelativeFilePath));
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОбновлениеИнформационнойБазы

// Заполняет очередь извлечения текста для текущей области данных. Используется для начального заполнения при
// обновлении.
//
Процедура ЗаполнитьОчередьИзвлеченияТекста() Экспорт
	
	ЭтоРазделеннаяКонфигурация = Ложь;
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		ЭтоРазделеннаяКонфигурация = МодульРаботаВМоделиСервиса.ЭтоРазделеннаяКонфигурация();
	КонецЕсли;
	
	Если Не ЭтоРазделеннаяКонфигурация Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = РаботаСФайламиСлужебный.ТекстЗапросаДляИзвлеченияТекста(Истина);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ОбновитьСостояниеОчередиИзвлеченияТекста(Выборка.Ссылка,
			Перечисления.СтатусыИзвлеченияТекстаФайлов.НеИзвлечен);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
// АПК:299-вкл

#Область ИзвлечениеТекста

// Определяет перечень областей данных, в которых требуется извлечение текста и планирует
// для них его выполнение с использованием очереди заданий.
//
Процедура ОбработатьОчередьИзвлеченияТекста() Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.ПланированиеИзвлеченияТекстаВМоделиСервиса);
	
	Если НЕ ОбщегоНазначения.РазделениеВключено()
		Или Не ОбщегоНазначения.ЭтоWindowsСервер() Тогда
		Возврат;
	КонецЕсли;
	
	МодульОчередьЗаданий = ОбщегоНазначения.ОбщийМодуль("ОчередьЗаданий");
	МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
	
	УстановитьПривилегированныйРежим(Истина);
	
	ИмяРазделенногоМетода = "РаботаСФайламиСлужебный.ИзвлечьТекстИзФайлов";
	
	ТекстЗапроса = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ОчередьИзвлеченияТекста.ОбластьДанныхВспомогательныеДанные КАК ОбластьДанных,
	|	ВЫБОР
	|		КОГДА ЧасовыеПояса.Значение = """"
	|			ТОГДА НЕОПРЕДЕЛЕНО
	|		ИНАЧЕ ЕСТЬNULL(ЧасовыеПояса.Значение, НЕОПРЕДЕЛЕНО)
	|	КОНЕЦ КАК ЧасовойПояс
	|ИЗ
	|	РегистрСведений.ОчередьИзвлеченияТекста КАК ОчередьИзвлеченияТекста
	|		ЛЕВОЕ СОЕДИНЕНИЕ Константа.ЧасовойПоясОбластиДанных КАК ЧасовыеПояса
	|		ПО ОчередьИзвлеченияТекста.ОбластьДанныхВспомогательныеДанные = ЧасовыеПояса.ОбластьДанныхВспомогательныеДанные
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОбластиДанных КАК ОбластиДанных
	|		ПО ОчередьИзвлеченияТекста.ОбластьДанныхВспомогательныеДанные = ОбластиДанных.ОбластьДанныхВспомогательныеДанные
	|ГДЕ
	|	НЕ ОчередьИзвлеченияТекста.ОбластьДанныхВспомогательныеДанные В (&ОбрабатываемыеОбластиДанных)
	|	И ОбластиДанных.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыОбластейДанных.Используется)";
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ОбрабатываемыеОбластиДанных", МодульОчередьЗаданий.ПолучитьЗадания(
		Новый Структура("ИмяМетода", ИмяРазделенногоМетода)));
		
	Если ТранзакцияАктивна() Тогда
		ВызватьИсключение(НСтр("ru = 'Транзакция активна. Выполнение запроса в транзакции невозможно.'"));
	КонецЕсли;
	
	КоличествоПопыток = 0;
	
	Результат = Неопределено;
	Пока Истина Цикл
		Попытка
			Результат = Запрос.Выполнить(); // Чтение вне транзакции, возможно появление ошибки.
			                                // Could not continue scan with NOLOCK due to data movement
			                                // в этом случае нужно повторить попытку чтения.
			Прервать;
		Исключение
			КоличествоПопыток = КоличествоПопыток + 1;
			Если КоличествоПопыток = 5 Тогда
				ВызватьИсключение;
			КонецЕсли;
		КонецПопытки;
	КонецЦикла;
		
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		// Проверка блокировки области.
		Если МодульРаботаВМоделиСервиса.ОбластьДанныхЗаблокирована(Выборка.ОбластьДанных) Тогда
			// Область заблокирована, перейти к следующей записи.
			Продолжить;
		КонецЕсли;
		
		НовоеЗадание = Новый Структура();
		НовоеЗадание.Вставить("ОбластьДанных", Выборка.ОбластьДанных);
		НовоеЗадание.Вставить("ЗапланированныйМоментЗапуска", МестноеВремя(ТекущаяУниверсальнаяДата(), Выборка.ЧасовойПояс));
		НовоеЗадание.Вставить("ИмяМетода", ИмяРазделенногоМетода);
		МодульОчередьЗаданий.ДобавитьЗадание(НовоеЗадание);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область Прочее

Функция ТипАртефактФайла()
	
	Возврат ФабрикаXDTO.Тип(Пакет(), "FileArtefact");
	
КонецФункции

Функция Пакет()
	
	Возврат "http://www.1c.ru/1cFresh/Data/Artefacts/Files/1.0.0.1";
	
КонецФункции

Функция ПрочитатьКэшВыгрузкиЗагрузкиФайловыхФункций()
	
	Возврат РаботаСФайламиСлужебныйВМоделиСервисаПовтИсп.СправочникиФайловИОбъектыХранения();
	
КонецФункции

Процедура ОчиститьСсылкаНаТомХраненияФайлов(Объект)
	
	Для Каждого РеквизитОбъекта Из Объект.Метаданные().Реквизиты Цикл
		Если РеквизитОбъекта.Тип.СодержитТип(Тип("СправочникСсылка.ТомаХраненияФайлов")) 
			И ЗначениеЗаполнено(Объект[РеквизитОбъекта.Имя]) Тогда
			Объект[РеквизитОбъекта.Имя] = Неопределено;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
