﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// Возвращает реквизиты объекта, которые не рекомендуется редактировать
// с помощью обработки группового изменения реквизитов.
//
// Возвращаемое значение:
//  Массив Из Строка -
Функция РеквизитыНеРедактируемыеВГрупповойОбработке() Экспорт
	
	Результат = Новый Массив;
	Результат.Добавить("*");
	Возврат Результат;
	
КонецФункции

// Конец СтандартныеПодсистемы.ГрупповоеИзменениеОбъектов

// СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов

// См. ЗапретРедактированияРеквизитовОбъектовПереопределяемый.ПриОпределенииОбъектовСЗаблокированнымиРеквизитами.
Функция ПолучитьБлокируемыеРеквизитыОбъекта() Экспорт
	
	БлокируемыеРеквизиты = Новый Массив;
	
	БлокируемыеРеквизиты.Добавить("Тип;Тип");
	БлокируемыеРеквизиты.Добавить("Родитель");
	
	Возврат БлокируемыеРеквизиты;
	
КонецФункции

// Конец СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов

// СтандартныеПодсистемы.ПоискИУдалениеДублей

// Анализирует пары ссылок справочника на возможность замены одной на другую 
// во всех местах использования с прикладной точки зрения.
// Проверки на запрет замены групп и ссылок разных типов производятся автоматически при начале замены.
//
// Параметры:
//     ПарыЗамен - Соответствие - Ключ - что будет заменено, значение - на что будет заменено.
//     Параметры - Структура    - Набор флагов, описывающих действие с заменяемыми элементами.
//                                Содержит необязательные реквизиты:
//                     * СпособУдаления - Строка, может принимать значения:
//                         "Непосредственно" - Если после замены ссылка нигде не используется,
//                                             то она будет удалена непосредственно
//                         "Пометка"         - Если после замены ссылка не используется, то
//                                             она будет помечена на удаление.
//                         Любые другие значения говорят о том, что заменяемая ссылка не будет изменена.
//
// Возвращаемое значение:
//     Соответствие - Ключ - исходная ссылка, значение - строка - описание, почему замена недопустима.
//                    Если все замены допустимы, то возвращается пустое соответствие;
//
Функция ВозможностьЗаменыЭлементов(Знач ПарыЗамен, Знач Параметры = Неопределено) Экспорт
	
	Результат = Новый Соответствие;
	Для Каждого КлючЗначение Из ПарыЗамен Цикл
		ТекущаяСсылка = КлючЗначение.Ключ;
		ЦелеваяСсылка = КлючЗначение.Значение;
		
		Если ТекущаяСсылка = ЦелеваяСсылка Тогда
			Продолжить;
		КонецЕсли;
		
		// Разрешаем заменять вид контактной информации на другой, только если они относятся к одной группе.
		МожноЗаменять = ТекущаяСсылка.Родитель = ЦелеваяСсылка.Родитель;
		Если Не МожноЗаменять Тогда
			Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Элемент ""%1"" относится к ""%2"", а ""%3"" - к ""%4""'"),
				ТекущаяСсылка, ТекущаяСсылка.Родитель, ЦелеваяСсылка, ЦелеваяСсылка.Родитель);
			Результат.Вставить(ТекущаяСсылка, Ошибка);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

// Вызывается для определения прикладных параметров поиска дублей.
//
// Параметры:
//
//     ПараметрыПоиска - Структура - Предлагаемые параметры поиска. Содержит поля:
//
//         *  ПравилаПоиска - ТаблицаЗначений - Предлагаемые правила сравнения для объектов.
//                            Может быть изменена для установки новых вариантов. Содержит колонки.
//               ** Реквизит - Строка - Имя реквизита для сравнения.
//               ** Правило  - Строка - Правило сравнения: "Равно" - сравнение по равенству, "Подобно" -подобие строк,
//                                     "" - пустая строка - не сравнивать.
//
//         * КомпоновщикОтбора - КомпоновщикНастроекКомпоновкиДанных - Инициализированный компоновщик для 
//                               предварительного отбора. Может быть изменен, например, для 
//                               усиления отборов.
// 
//         * ОграниченияСравнения - Массив - Предназначен для заполнения описания прикладных правил-ограничений.
//                                  Должен быть дополнен структурами с полями:
//               ** Представление      - Строка - Описание правила-ограничения для пользователя.
//               ** ДополнительныеПоля - Строка - Список дополнительных реквизитов запятую, необходимых для
//                                                дополнительного анализа.
// 
//         * КоличествоЭлементовДляСравнения - Число - Количество кандидатов в дубли, передаваемых одним вызовом
//                                                     обработчику.
//
//     ДополнительныеПараметры - Произвольный - Значение, переданное при вызове программного интерфейса
//                                              ОбщегоНазначения.НайтиДублиЭлементов.
//                               При вызове пользователем из обработки "ПоискИЗаменаДублей" равно Неопределено.
// 
Процедура ПараметрыПоискаДублей(ПараметрыПоиска, ДополнительныеПараметры = Неопределено) Экспорт
	
	Ограничение = Новый Структура;
	Ограничение.Вставить("Представление",      НСтр("ru = 'Относятся к одной группе и одного типа (адрес, телефон и пр.).'"));
	Ограничение.Вставить("ДополнительныеПоля", "Родитель, Тип");
	ПараметрыПоиска.ОграниченияСравнения.Добавить(Ограничение);
	
	// Размер таблицы для передачи в обработчик.
	ПараметрыПоиска.КоличествоЭлементовДляСравнения = 100;
	
КонецПроцедуры

// Вызывается для определения дублей по прикладным правилам.
//
// Параметры:
//
//     ТаблицаКандидатов - ТаблицаЗначений - Описывает кандидатов в дубли. Содержит колонки:
//         - Ссылка1  - ЛюбаяСсылка - Ссылка на элемент первого кандидата.
//         - Ссылка2  - ЛюбаяСсылка - Ссылка на элемент второго кандидата.
//         - ЭтоДубли - Булево      - Флаг того, что кандидаты действительно являются дублями. По умолчанию содержит 
//                                    значение Ложь, может быть изменено на Истина, если кандидаты - действительно
//                                    дубли.
//         - Поля1    - Структура   - Содержит поля Код, Наименование и дополнительные поля первого кандидата,
//         указанные в ПараметрыПоискаДублей.
//         - Поля2    - Структура   - Содержит поля Код, Наименование и дополнительные поля второго кандидата,
//         указанные в ПараметрыПоискаДублей.
//
//     ДополнительныеПараметры - Произвольный - Значение, переданное при вызове программного интерфейса
//                                              ОбщегоНазначения.НайтиДублиЭлементов.
//                               При вызове пользователем из обработки "ПоискИЗаменаДублей" равно Неопределено.
//
Процедура ПриПоискеДублей(ТаблицаКандидатов, ДополнительныеПараметры = Неопределено) Экспорт
	
	Для Каждого Вариант Из ТаблицаКандидатов Цикл
		Если Вариант.Поля1.Родитель = Вариант.Поля2.Родитель И Вариант.Поля1.Тип = Вариант.Поля2.Тип Тогда
			Вариант.ЭтоДубли = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ПоискИУдалениеДублей

#КонецОбласти

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	МультиязычностьКлиентСервер.ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка);
КонецПроцедуры

#КонецОбласти

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Регистрирует к обработке виды контактной информации.
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	ВидыКонтактнойИнформации.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ВидыКонтактнойИнформации КАК ВидыКонтактнойИнформации";
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();

	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры,
		РезультатЗапроса.ВыгрузитьКолонку("Ссылка"));
	
КонецПроцедуры

Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт
	
	ВидКонтактнойИнформацииСсылка = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, "Справочник.ВидыКонтактнойИнформации");
	
	ЯзыковБольшеОдного = Метаданные.Языки.Количество() > 1;
	Наименования = УправлениеКонтактнойИнформациейСлужебныйПовтИсп.НаименованияВидовКонтактнойИнформации();
	
	ПроблемныхОбъектов = 0;
	ОбъектовОбработано = 0;
	
	Пока ВидКонтактнойИнформацииСсылка.Следующий() Цикл
		Попытка
			ВидКонтактнойИнформации = ВидКонтактнойИнформацииСсылка.Ссылка.ПолучитьОбъект(); // СправочникОбъект.ВидыКонтактнойИнформации
			
			// Исправление наименований на разных языках
			Если ЯзыковБольшеОдного Тогда
				ИмяВида = ?(ЗначениеЗаполнено(ВидКонтактнойИнформации.ИмяПредопределенногоВида),
					ВидКонтактнойИнформации.ИмяПредопределенногоВида, ВидКонтактнойИнформации.ИмяПредопределенныхДанных);
				
				Если ЗначениеЗаполнено(ИмяВида) Тогда
					УстановитьНаименованияВидовКонтактнойИнформации(ВидКонтактнойИнформации, ИмяВида, Наименования);
				КонецЕсли;
			КонецЕсли;
			
			Если Не ВидКонтактнойИнформации.ЭтоГруппа Тогда
				Если ВидКонтактнойИнформации.УдалитьРедактированиеТолькоВДиалоге Тогда
					ВидКонтактнойИнформации.ВидРедактирования = "Диалог";
				ИначеЕсли ВидКонтактнойИнформации.Тип = Перечисления.ТипыКонтактнойИнформации.АдресЭлектроннойПочты
						Или ВидКонтактнойИнформации.Тип = Перечисления.ТипыКонтактнойИнформации.Skype
						Или ВидКонтактнойИнформации.Тип = Перечисления.ТипыКонтактнойИнформации.Другое Тогда
						ВидКонтактнойИнформации.ВидРедактирования = "ПолеВвода";
				ИначеЕсли ВидКонтактнойИнформации.Тип = Перечисления.ТипыКонтактнойИнформации.ВебСтраница Тогда
					ВидКонтактнойИнформации.ВидРедактирования = "Диалог";
				Иначе
					ВидКонтактнойИнформации.ВидРедактирования = "ПолеВводаИДиалог";
				КонецЕсли;
			КонецЕсли;
			ОбновлениеИнформационнойБазы.ЗаписатьДанные(ВидКонтактнойИнформации);
			ОбъектовОбработано = ОбъектовОбработано + 1;
			
		Исключение
			// Если не удалось обработать какой-либо вид контактной информации, повторяем попытку снова.
			ПроблемныхОбъектов = ПроблемныхОбъектов + 1;
			
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось обработать вид контактной информации: %1 по причине: %2'"),
					ВидКонтактнойИнформацииСсылка.Ссылка, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,
				Метаданные.Справочники.ВидыКонтактнойИнформации, ВидКонтактнойИнформацииСсылка.Ссылка, ТекстСообщения);
		КонецПопытки;
	КонецЦикла;
	
	Параметры.ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(Параметры.Очередь, "Справочник.ВидыКонтактнойИнформации");
	
	Если ОбъектовОбработано = 0 И ПроблемныхОбъектов <> 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Процедуре ЗаполнитьВидыКонтактнойИнформации не удалось обработать некоторые виды контактной информации (пропущены): %1'"), 
				ПроблемныхОбъектов);
		ВызватьИсключение ТекстСообщения;
	Иначе
		ЗаписьЖурналаРегистрации(ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,
			Метаданные.Справочники.ВидыКонтактнойИнформации,,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Процедура ЗаполнитьВидыКонтактнойИнформации обработала очередную порцию видов контактной информации: %1'"),
					ОбъектовОбработано));
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьНаименованияВидовКонтактнойИнформации(ВидКонтактнойИнформации, ИмяВида, Наименования)
	
	Для Каждого Язык Из Метаданные.Языки Цикл
		
		Представление = Наименования[Язык.КодЯзыка][ИмяВида];
		Если ЗначениеЗаполнено(Представление) Тогда
			
			Если Язык = Метаданные.ОсновнойЯзык Тогда
				ВидКонтактнойИнформации.Наименование = Представление;
			Иначе
				
				Если Наименования[Язык.КодЯзыка][ИмяВида] <> Неопределено Тогда
					
					Отбор = Новый Структура;
					Отбор.Вставить("КодЯзыка",     Язык.КодЯзыка);
					Отбор.Вставить("Наименование", Представление);
					НайденныеСтроки = ВидКонтактнойИнформации.Представления.НайтиСтроки(Отбор);
					Если НайденныеСтроки.Количество() > 0 Тогда
						НоваяСтрока = НайденныеСтроки[0];
					Иначе
						НоваяСтрока = ВидКонтактнойИнформации.Представления.Добавить();
					КонецЕсли;
					НоваяСтрока.КодЯзыка     = Язык.КодЯзыка;
					НоваяСтрока.Наименование = Представление;
				КонецЕсли;
				
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти


#КонецЕсли