﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

#Область ЗапускВнешнихПриложений

// Параметры:
//  КомандаЗапуска - Строка
// 
// Возвращаемое значение:
//  Строка
//
Функция БезопаснаяСтрокаКоманды(КомандаЗапуска) Экспорт
	
	Результат = "";
	
	Если ТипЗнч(КомандаЗапуска) = Тип("Строка") Тогда 
		
		ПроверитьСодержитНебезопасныеДействия(КомандаЗапуска);
		Результат = КомандаЗапуска;
		
	ИначеЕсли ТипЗнч(КомандаЗапуска) = Тип("Массив") Тогда
		
		Если КомандаЗапуска.Количество() > 0 Тогда
			ПроверитьСодержитНебезопасныеДействия(КомандаЗапуска[0]);
			Результат = МассивВСтрокуКоманды(КомандаЗапуска);
		Иначе
			ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ожидалось, что первый элемент массива %1 будет командой или путем к исполняемому файлу.'"),
				"КомандаЗапуска");
		КонецЕсли;
		
	Иначе
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ожидалось, что значение %1 будет типа %2 или %3.'"), 
			"КомандаЗапуска", "Строка", "Массив");
	КонецЕсли;
		
	Возврат Результат
	
КонецФункции

#КонецОбласти

#Область Прочее

// Рассчитывает показатели числовых ячеек в табличном документе.
//
// Параметры:
//   ТабличныйДокумент - ТабличныйДокумент - табличный документ, показатели которого рассчитываются.
//   ВыделенныеОбласти - Массив из см. ОбщегоНазначенияСлужебныйКлиентСервер.ПараметрыРасчетаПоказателейЯчеек.
//
// Возвращаемое значение:
//   Структура - результаты расчета выделенных ячеек:
//       * Количество         - Число - количество выделенных ячеек.
//       * КоличествоЧисловых - Число - количество числовых ячеек.
//       * Сумма      - Число - сумма выделенных ячеек с числами.
//       * Среднее    - Число - сумма выделенных ячеек с числами.
//       * Минимум    - Число - сумма выделенных ячеек с числами.
//       * Максимум   - Число - максимум выделенных ячеек с числами.
//
Функция РасчетныеПоказателиЯчеек(Знач ТабличныйДокумент, ВыделенныеОбласти) Экспорт 
	
	#Область КонструкторРезультата
	
	РасчетныеПоказатели = Новый Структура;
	РасчетныеПоказатели.Вставить("Количество", 0);
	РасчетныеПоказатели.Вставить("КоличествоНеПустых", 0);
	РасчетныеПоказатели.Вставить("КоличествоЧисловых", 0);
	РасчетныеПоказатели.Вставить("Сумма", 0);
	РасчетныеПоказатели.Вставить("Среднее", 0);
	РасчетныеПоказатели.Вставить("Минимум", 0);
	РасчетныеПоказатели.Вставить("Максимум", 0);
	
	#КонецОбласти
	
	ПроверенныеЯчейки = Новый Соответствие;
	
	Для Каждого ВыделеннаяОбласть Из ВыделенныеОбласти Цикл
		
		Если ТипЗнч(ВыделеннаяОбласть) <> Тип("ОбластьЯчеекТабличногоДокумента")
			И ТипЗнч(ВыделеннаяОбласть) <> Тип("Структура") Тогда
			Продолжить;
		КонецЕсли;
		
		#Область ОпределениеГраницВыделеннойОбласти
		
		ВыделеннаяОбластьВерх  = ВыделеннаяОбласть.Верх;
		ВыделеннаяОбластьНиз   = ВыделеннаяОбласть.Низ;
		ВыделеннаяОбластьЛево  = ВыделеннаяОбласть.Лево;
		ВыделеннаяОбластьПраво = ВыделеннаяОбласть.Право;
		
		Если ВыделеннаяОбластьВерх = 0 Тогда
			ВыделеннаяОбластьВерх = 1;
		КонецЕсли;
		
		Если ВыделеннаяОбластьНиз = 0 Тогда
			ВыделеннаяОбластьНиз = ТабличныйДокумент.ВысотаТаблицы;
		КонецЕсли;
		
		Если ВыделеннаяОбластьЛево = 0 Тогда
			ВыделеннаяОбластьЛево = 1;
		КонецЕсли;
		
		Если ВыделеннаяОбластьПраво = 0 Тогда
			ВыделеннаяОбластьПраво = ТабличныйДокумент.ШиринаТаблицы;
		КонецЕсли;
		
		Если ВыделеннаяОбласть.ТипОбласти = ТипОбластиЯчеекТабличногоДокумента.Колонки Тогда
			ВыделеннаяОбластьВерх = ВыделеннаяОбласть.Низ;
			ВыделеннаяОбластьНиз = ТабличныйДокумент.ВысотаТаблицы;
		КонецЕсли;
		
		ВыделеннаяОбластьВысота = ВыделеннаяОбластьНиз   - ВыделеннаяОбластьВерх + 1;
		ВыделеннаяОбластьШирина = ВыделеннаяОбластьПраво - ВыделеннаяОбластьЛево + 1;
		
		#КонецОбласти
		
		РасчетныеПоказатели.Количество = РасчетныеПоказатели.Количество + ВыделеннаяОбластьШирина * ВыделеннаяОбластьВысота;
		
		Для НомерКолонки = ВыделеннаяОбластьЛево По ВыделеннаяОбластьПраво Цикл
			
			Для НомерСтроки = ВыделеннаяОбластьВерх По ВыделеннаяОбластьНиз Цикл
				
				Ячейка = ТабличныйДокумент.Область(НомерСтроки, НомерКолонки, НомерСтроки, НомерКолонки);
				
				Если ПроверенныеЯчейки.Получить(Ячейка.Имя) = Неопределено Тогда
					ПроверенныеЯчейки.Вставить(Ячейка.Имя, Истина);
				Иначе
					Продолжить;
				КонецЕсли;
				
				Если Ячейка.Видимость = Истина Тогда
					
					#Область ОпределениеЗначенияЯчейки
					
					Если Ячейка.ТипОбласти <> ТипОбластиЯчеекТабличногоДокумента.Колонки
						И Ячейка.СодержитЗначение И ТипЗнч(Ячейка.Значение) = Тип("Число") Тогда
						
						Число = Ячейка.Значение;
						
					ИначеЕсли ЗначениеЗаполнено(Ячейка.Текст) Тогда
						
						ТекстЯчейки = СтрЗаменить(Ячейка.Текст, " ", "");
						
						Если ТекстЯчейкиВидаЭкспоненциальнойЗаписи(ТекстЯчейки) Тогда 
							Число = 0;
						Иначе
							ОписаниеТипаЧисло = Новый ОписаниеТипов("Число");
							
							Если СтрНачинаетсяС(ТекстЯчейки, "(")
								И СтрЗаканчиваетсяНа(ТекстЯчейки, ")") Тогда 
								
								ТекстЯчейки = СтрЗаменить(ТекстЯчейки, "(", "");
								ТекстЯчейки = СтрЗаменить(ТекстЯчейки, ")", "");
								
								Число = ОписаниеТипаЧисло.ПривестиЗначение(ТекстЯчейки);
								Если Число > 0 Тогда 
									Число = -Число;
								КонецЕсли;
							Иначе
								Число = ОписаниеТипаЧисло.ПривестиЗначение(ТекстЯчейки);
							КонецЕсли;
						КонецЕсли;
						
					Иначе
						Продолжить;
					КонецЕсли;
					
					#КонецОбласти
					
					РасчетныеПоказатели.КоличествоНеПустых = РасчетныеПоказатели.КоличествоНеПустых + 1;
					
					#Область РасчетПоказателей
					
					Если ТипЗнч(Число) = Тип("Число") Тогда
						
						РасчетныеПоказатели.КоличествоЧисловых = РасчетныеПоказатели.КоличествоЧисловых + 1;
						РасчетныеПоказатели.Сумма = РасчетныеПоказатели.Сумма + Число;
						
						Если РасчетныеПоказатели.КоличествоЧисловых = 1 Тогда
							РасчетныеПоказатели.Минимум  = Число;
							РасчетныеПоказатели.Максимум = Число;
						Иначе
							РасчетныеПоказатели.Минимум  = Мин(Число,  РасчетныеПоказатели.Минимум);
							РасчетныеПоказатели.Максимум = Макс(Число, РасчетныеПоказатели.Максимум);
						КонецЕсли;
						
					КонецЕсли;
					
					#КонецОбласти
					
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Если РасчетныеПоказатели.КоличествоЧисловых > 0 Тогда
		РасчетныеПоказатели.Среднее = РасчетныеПоказатели.Сумма / РасчетныеПоказатели.КоличествоЧисловых;
	КонецЕсли;
	
	Возврат РасчетныеПоказатели;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ОповещениеПользователя

Процедура СообщитьПользователю(
		Знач ТекстСообщенияПользователю,
		Знач КлючДанных,
		Знач Поле,
		Знач ПутьКДанным = "",
		Отказ = Ложь,
		ЭтоОбъект = Ложь) Экспорт
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстСообщенияПользователю;
	Сообщение.Поле = Поле;
	
	Если ЭтоОбъект Тогда
		Сообщение.УстановитьДанные(КлючДанных);
	Иначе
		Сообщение.КлючДанных = КлючДанных;
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(ПутьКДанным) Тогда
		Сообщение.ПутьКДанным = ПутьКДанным;
	КонецЕсли;
	
	Сообщение.Сообщить();
	
	Отказ = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ДанныеВБазе

#Область ПредопределенныйЭлемент

Функция ИспользоватьСтандартнуюФункциюПолученияПредопределенного(ПолноеИмяПредопределенного) Экспорт
	
	// Используется стандартная функция платформы для получения:
	//  - пустых ссылок; 
	//  - значений перечислений;
	//  - точек маршрута бизнес-процессов.
	
	Возврат ".ПУСТАЯССЫЛКА" = ВРег(Прав(ПолноеИмяПредопределенного, 13))
		Или "ПЕРЕЧИСЛЕНИЕ." = ВРег(Лев(ПолноеИмяПредопределенного, 13))
		Или "БИЗНЕСПРОЦЕСС." = ВРег(Лев(ПолноеИмяПредопределенного, 14));
	
КонецФункции

Функция ИмяПредопределенногоПоПолям(ПолноеИмяПредопределенного) Экспорт
	
	ЧастиПолногоИмени = СтрРазделить(ПолноеИмяПредопределенного, ".");
	Если ЧастиПолногоИмени.Количество() <> 3 Тогда 
		ВызватьИсключение ТекстОшибкиПредопределенноеЗначениеНеНайдено(ПолноеИмяПредопределенного);
	КонецЕсли;
	
	ПолноеИмяОбъектаМетаданных = ВРег(ЧастиПолногоИмени[0] + "." + ЧастиПолногоИмени[1]);
	ИмяПредопределенного = ЧастиПолногоИмени[2];
	
	Результат = Новый Структура;
	Результат.Вставить("ПолноеИмяОбъектаМетаданных", ПолноеИмяОбъектаМетаданных);
	Результат.Вставить("ИмяПредопределенного", ИмяПредопределенного);
	
	Возврат Результат;
	
КонецФункции

Функция ПредопределенныйЭлемент(ПолноеИмяПредопределенного, ПоляПредопределенного, ПредопределенныеЗначения) Экспорт
	
	// Если ошибка в имени метаданных.
	Если ПредопределенныеЗначения = Неопределено Тогда 
		ВызватьИсключение ТекстОшибкиПредопределенноеЗначениеНеНайдено(ПолноеИмяПредопределенного);
	КонецЕсли;
	
	// Получение результата из кэша.
	Результат = ПредопределенныеЗначения.Получить(ПоляПредопределенного.ИмяПредопределенного);
	
	// Если предопределенного нет в метаданных.
	Если Результат = Неопределено Тогда 
		ВызватьИсключение ТекстОшибкиПредопределенноеЗначениеНеНайдено(ПолноеИмяПредопределенного);
	КонецЕсли;
	
	// Если предопределенный есть в метаданных, но не создан в ИБ.
	Если Результат = Null Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ТекстОшибкиПредопределенноеЗначениеНеНайдено(ПолноеИмяПредопределенного) Экспорт
	
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Предопределенное значение ""%1"" не существует.'"), ПолноеИмяПредопределенного);
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область Даты

Функция ПредставлениеЛокальнойДатыСоСмещением(ЛокальнаяДата, Смещение) Экспорт
	
	ПредставлениеСмещения = "Z";
	
	Если Смещение > 0 Тогда
		ПредставлениеСмещения = "+";
	ИначеЕсли Смещение < 0 Тогда
		ПредставлениеСмещения = "-";
		Смещение = -Смещение;
	КонецЕсли;
	
	Если Смещение <> 0 Тогда
		ПредставлениеСмещения = ПредставлениеСмещения + Формат('00010101' + Смещение, "ДФ=HH:mm");
	КонецЕсли;
	
	Возврат Формат(ЛокальнаяДата, "ДФ=yyyy-MM-ddTHH:mm:ss; ДП=0001-01-01T00:00:00") + ПредставлениеСмещения;
	
КонецФункции

#КонецОбласти

#Область ВнешнееСоединение

Функция УстановитьВнешнееСоединениеСБазой(Параметры, ПодключениеНедоступно, КраткоеОписаниеОшибки) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Соединение");
	Результат.Вставить("КраткоеОписаниеОшибки", "");
	Результат.Вставить("ПодробноеОписаниеОшибки", "");
	Результат.Вставить("ОшибкаПодключенияКомпоненты", Ложь);
	
#Если МобильныйКлиент Тогда
	
	СтрокаСообщенияОбОшибке = НСтр("ru = 'Подключение к другой программе не доступно в мобильном клиенте.'");
	
	Результат.ОшибкаПодключенияКомпоненты = Истина;
	Результат.ПодробноеОписаниеОшибки = СтрокаСообщенияОбОшибке;
	Результат.КраткоеОписаниеОшибки = СтрокаСообщенияОбОшибке;
	
	Возврат Результат;
	
#Иначе
	
	Если ПодключениеНедоступно Тогда
		Результат.Соединение = Неопределено;
		Результат.КраткоеОписаниеОшибки = КраткоеОписаниеОшибки;
		Результат.ПодробноеОписаниеОшибки = КраткоеОписаниеОшибки;
		Возврат Результат;
	КонецЕсли;
	
	Попытка
		COMConnector = Новый COMObject(ОбщегоНазначенияКлиентСервер.ИмяCOMСоединителя()); // "V83.COMConnector"
	Исключение
		Информация = ИнформацияОбОшибке();
		СтрокаСообщенияОбОшибке = НСтр("ru = 'Не удалось подключиться к другой программе: %1'");
		
		Результат.ОшибкаПодключенияКомпоненты = Истина;
		Результат.ПодробноеОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщенияОбОшибке, ПодробноеПредставлениеОшибки(Информация));
		Результат.КраткоеОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщенияОбОшибке, КраткоеПредставлениеОшибки(Информация));
		
		Возврат Результат;
	КонецПопытки;
	
	ФайловыйВариантРаботы = Параметры.ВариантРаботыИнформационнойБазы = 0;
	
	// Проверка корректности указания параметров.
	ОшибкаПроверкиЗаполнения = Ложь;
	Если ФайловыйВариантРаботы Тогда
		
		Если ПустаяСтрока(Параметры.КаталогИнформационнойБазы) Тогда
			СтрокаСообщенияОбОшибке = НСтр("ru = 'Не задано месторасположение каталога информационной базы.'");
			ОшибкаПроверкиЗаполнения = Истина;
		КонецЕсли;
		
	Иначе
		
		Если ПустаяСтрока(Параметры.ИмяСервера1СПредприятия) Или ПустаяСтрока(Параметры.ИмяИнформационнойБазыНаСервере1СПредприятия) Тогда
			СтрокаСообщенияОбОшибке = НСтр("ru = 'Не заданы обязательные параметры подключения: ""Имя сервера""; ""Имя информационной базы на сервере"".'");
			ОшибкаПроверкиЗаполнения = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Если ОшибкаПроверкиЗаполнения Тогда
		
		Результат.ПодробноеОписаниеОшибки = СтрокаСообщенияОбОшибке;
		Результат.КраткоеОписаниеОшибки   = СтрокаСообщенияОбОшибке;
		Возврат Результат;
		
	КонецЕсли;
	
	// Формирование строки соединения.
	ШаблонСтрокиСоединения = "[СтрокаБазы][СтрокаАутентификации]";
	
	Если ФайловыйВариантРаботы Тогда
		СтрокаБазы = "File = ""&КаталогИнформационнойБазы""";
		СтрокаБазы = СтрЗаменить(СтрокаБазы, "&КаталогИнформационнойБазы", Параметры.КаталогИнформационнойБазы);
	Иначе
		СтрокаБазы = "Srvr = ""&ИмяСервера1СПредприятия""; Ref = ""&ИмяИнформационнойБазыНаСервере1СПредприятия""";
		СтрокаБазы = СтрЗаменить(СтрокаБазы, "&ИмяСервера1СПредприятия",                     Параметры.ИмяСервера1СПредприятия);
		СтрокаБазы = СтрЗаменить(СтрокаБазы, "&ИмяИнформационнойБазыНаСервере1СПредприятия", Параметры.ИмяИнформационнойБазыНаСервере1СПредприятия);
	КонецЕсли;
	
	Если Параметры.АутентификацияОперационнойСистемы Тогда
		СтрокаАутентификации = "";
	Иначе
		
		Если СтрНайти(Параметры.ИмяПользователя, """") Тогда
			Параметры.ИмяПользователя = СтрЗаменить(Параметры.ИмяПользователя, """", """""");
		КонецЕсли;
		
		Если СтрНайти(Параметры.ПарольПользователя, """") Тогда
			Параметры.ПарольПользователя = СтрЗаменить(Параметры.ПарольПользователя, """", """""");
		КонецЕсли;
		
		СтрокаАутентификации = "; Usr = ""&ИмяПользователя""; Pwd = ""&ПарольПользователя""";
		СтрокаАутентификации = СтрЗаменить(СтрокаАутентификации, "&ИмяПользователя",    Параметры.ИмяПользователя);
		СтрокаАутентификации = СтрЗаменить(СтрокаАутентификации, "&ПарольПользователя", Параметры.ПарольПользователя);
	КонецЕсли;
	
	СтрокаСоединения = СтрЗаменить(ШаблонСтрокиСоединения, "[СтрокаБазы]", СтрокаБазы);
	СтрокаСоединения = СтрЗаменить(СтрокаСоединения, "[СтрокаАутентификации]", СтрокаАутентификации);
	
	Попытка
		Результат.Соединение = COMConnector.Connect(СтрокаСоединения);
	Исключение
		Информация = ИнформацияОбОшибке();
		СтрокаСообщенияОбОшибке = НСтр("ru = 'Не удалось подключиться к другой программе: %1'");
		
		Результат.ОшибкаПодключенияКомпоненты = Истина;
		Результат.ПодробноеОписаниеОшибки     = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщенияОбОшибке, ПодробноеПредставлениеОшибки(Информация));
		Результат.КраткоеОписаниеОшибки       = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаСообщенияОбОшибке, КраткоеПредставлениеОшибки(Информация));
	КонецПопытки;
	
	Возврат Результат;
	
#КонецЕсли
	
КонецФункции

#КонецОбласти

#Область ЗапускВнешнихПриложений

#Область БезопаснаяСтрокаКоманды

Функция СодержитНебезопасныеДействия(Знач СтрокаКоманды)
	
	Возврат СтрНайти(СтрокаКоманды, "${") <> 0
		Или СтрНайти(СтрокаКоманды, "$(") <> 0
		Или СтрНайти(СтрокаКоманды, "`") <> 0
		Или СтрНайти(СтрокаКоманды, "|") <> 0
		Или СтрНайти(СтрокаКоманды, ";") <> 0
		Или СтрНайти(СтрокаКоманды, "&") <> 0;
	
КонецФункции

Процедура ПроверитьСодержитНебезопасныеДействия(Знач КомандаЗапуска)
	Если СодержитНебезопасныеДействия(КомандаЗапуска) Тогда 
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось запустить программу.
			           |Недопустимая строка команды
			           |%1
			           |
			           |Строка команды не должна содержать символы: ""${"", ""$("", ""`"", ""|"", "";"", ""&"".'"),
			КомандаЗапуска);
	КонецЕсли;
КонецПроцедуры

Функция МассивВСтрокуКоманды(КомандаЗапуска)
	
	Результат = Новый Массив;
	НужныКавычки = Ложь;
	Для Каждого Аргумент Из КомандаЗапуска Цикл
		
		Если Результат.Количество() > 0 Тогда 
			Результат.Добавить(" ")
		КонецЕсли;
		
		НужныКавычки = Аргумент = Неопределено
			Или ПустаяСтрока(Аргумент)
			Или СтрНайти(Аргумент, " ")
			Или СтрНайти(Аргумент, Символы.Таб)
			Или СтрНайти(Аргумент, "&")
			Или СтрНайти(Аргумент, "(")
			Или СтрНайти(Аргумент, ")")
			Или СтрНайти(Аргумент, "[")
			Или СтрНайти(Аргумент, "]")
			Или СтрНайти(Аргумент, "{")
			Или СтрНайти(Аргумент, "}")
			Или СтрНайти(Аргумент, "^")
			Или СтрНайти(Аргумент, "=")
			Или СтрНайти(Аргумент, ";")
			Или СтрНайти(Аргумент, "!")
			Или СтрНайти(Аргумент, "'")
			Или СтрНайти(Аргумент, "+")
			Или СтрНайти(Аргумент, ",")
			Или СтрНайти(Аргумент, "`")
			Или СтрНайти(Аргумент, "~")
			Или СтрНайти(Аргумент, "$")
			Или СтрНайти(Аргумент, "|");
		
		Если НужныКавычки Тогда 
			Результат.Добавить("""");
		КонецЕсли;
		
		Результат.Добавить(СтрЗаменить(Аргумент, """", """"""));
		
		Если НужныКавычки Тогда 
			Результат.Добавить("""");
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат СтрСоединить(Результат);
	
КонецФункции

#КонецОбласти

#Если Не ВебКлиент И Не МобильныйКлиент Тогда

Функция СтрокаЗапускаКомандыWindows(СтрокаКоманды, ТекущийКаталог, ДождатьсяЗавершения, КодировкаИсполнения) Экспорт
	
	НаборКоманд = "";
	
	Если ЗначениеЗаполнено(КодировкаИсполнения) Тогда 
		
		Если КодировкаИсполнения = "OEM" Тогда
			КодировкаИсполнения = 437;
		ИначеЕсли КодировкаИсполнения = "CP866" Тогда
			КодировкаИсполнения = 866;
		ИначеЕсли КодировкаИсполнения = "UTF8" Тогда
			КодировкаИсполнения = 65001;
		КонецЕсли;
		
		НаборКоманд = "(chcp " + Формат(КодировкаИсполнения, "ЧГ=") + ")";
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекущийКаталог) Тогда 
		НаборКоманд = НаборКоманд + ?(ЗначениеЗаполнено(НаборКоманд), "&&", "") + "(cd /D """ + ТекущийКаталог + """)";
	КонецЕсли;
	НаборКоманд = НаборКоманд + ?(ЗначениеЗаполнено(НаборКоманд), "&&", "") + "(" + СокрЛП(СтрокаКоманды) + ")";
	
	Возврат "cmd /S /C """ + НаборКоманд + """";
	
КонецФункции

Функция НовыйФайлЗапускаКомандыWindows(СтрокаКоманды, ТекущийКаталог, ДождатьсяЗавершения, КодировкаИсполнения) Экспорт
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку("@echo off");
	
	Если ЗначениеЗаполнено(КодировкаИсполнения) Тогда 
		
		Если КодировкаИсполнения = "OEM" Тогда
			КодировкаИсполнения = 437;
		ИначеЕсли КодировкаИсполнения = "CP866" Тогда
			КодировкаИсполнения = 866;
		ИначеЕсли КодировкаИсполнения = "UTF8" Тогда
			КодировкаИсполнения = 65001;
		КонецЕсли;
		
		ТекстовыйДокумент.ДобавитьСтроку("chcp " + Формат(КодировкаИсполнения, "ЧГ="));
		
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекущийКаталог) Тогда 
		ТекстовыйДокумент.ДобавитьСтроку("cd /D """ + ТекущийКаталог + """");
	КонецЕсли;
	ТекстовыйДокумент.ДобавитьСтроку("cmd /S /C "" " + СтрокаКоманды + " """);
	
	Возврат ТекстовыйДокумент;
	
КонецФункции

#КонецЕсли

#КонецОбласти

#Область СтроковыеФункции

Функция СтрокаЛатиницей(Знач Значение, ПравилаТранслитерации) Экспорт
	
	Результат = "";
	ТолькоЗаглавныеВСтроке = ТолькоЗаглавныеВСтроке(Значение);
	
	Для Позиция = 1 По СтрДлина(Значение) Цикл
		Символ = Сред(Значение, Позиция, 1);
		СимволЛатиницей = ПравилаТранслитерации[НРег(Символ)]; // Поиск соответствия без учета регистра.
		Если СимволЛатиницей = Неопределено Тогда
			// Другие символы остаются "как есть".
			СимволЛатиницей = Символ;
		Иначе
			Если ТолькоЗаглавныеВСтроке Тогда 
				СимволЛатиницей = ВРег(СимволЛатиницей); // восстанавливаем регистр
			ИначеЕсли Символ = ВРег(Символ) Тогда
				СимволЛатиницей = ТРег(СимволЛатиницей); // восстанавливаем регистр
			КонецЕсли;
		КонецЕсли;
		Результат = Результат + СимволЛатиницей;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ТолькоЗаглавныеВСтроке(Значение)
	
	Для Позиция = 1 По СтрДлина(Значение) Цикл
		Символ = Сред(Значение, Позиция, 1);
		Если Символ <> ВРег(Символ) Тогда 
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

// Возвращает представление периода в нижнем регистре или с заглавной буквы,
//  если с него начинается фраза (предложение).
//  Например, если требуется вывести представление периода в заголовке отчета
//  в формате "Продажи за [ДатаНачала] - [ДатаОкончания]", то ожидается, что
//  результат будет выглядеть так: "Продажи за февраль 2020 г. - март 2020 г.".
//  Т.е. - строчно, т.к. "февраль 2020 г. - март 2020 г." не является началом предложения.
//
// Параметры:
//  ДатаНачала - Дата - начало периода.
//  ДатаОкончания - Дата - конец периода.
//  ФорматнаяСтрока - Строка - определяет способ форматирования периода.
//  СЗаглавнойБуквы - Булево - Истина, если с представления периода начинается предложение.
//                    По умолчанию - Ложь.
//
// Возвращаемое значение:
//   Строка - представление периода в требуемом формате и регистре.
//
Функция ПредставлениеПериодаВТексте(ДатаНачала, ДатаОкончания, ФорматнаяСтрока, СЗаглавнойБуквы) Экспорт 
	
	Если ДатаНачала > ДатаОкончания Тогда 
		Возврат "";
	КонецЕсли;
	
	ПредставлениеПериода = НРег(ПредставлениеПериода(ДатаНачала, ДатаОкончания, ФорматнаяСтрока));
	
	ОтформатироватьПредставлениеПериода(ПредставлениеПериода, ДатаНачала, ДатаОкончания, ФорматнаяСтрока);
	
	Если СЗаглавнойБуквы Тогда 
		ПредставлениеПериода = ВРег(Сред(ПредставлениеПериода, 1, 1)) + Сред(ПредставлениеПериода, 2);
	КонецЕсли;
	
	Возврат ПредставлениеПериода;
	
КонецФункции

Процедура ОтформатироватьПредставлениеПериода(ПредставлениеПериода, ДатаНачала, ДатаОкончания, ФорматнаяСтрока)
	
	Если ЗначениеЗаполнено(ФорматнаяСтрока) Тогда 
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ПредставлениеПериода) Тогда 
		
		ПредставлениеПериода = НСтр("ru = 'за все время'");
		Возврат;
		
	КонецЕсли;
	
	Если Месяц(ДатаНачала) > 1
		Или Год(ДатаНачала) <> Год(ДатаОкончания)
		Или ДатаНачала <> НачалоМесяца(ДатаНачала)
		Или ДатаОкончания <> КонецМесяца(ДатаОкончания) Тогда 
		
		Возврат;
	КонецЕсли;
		
	Если Месяц(ДатаОкончания) = 6 Тогда 
		
		ПредставлениеПериода = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '1 полугодие %1 г.'"), Формат(Год(ДатаНачала), "ЧГ=0"));
		
	ИначеЕсли Месяц(ДатаОкончания) = 9 Тогда 
		
		ПредставлениеПериода = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '9 месяцев %1 г.'"), Формат(Год(ДатаНачала), "ЧГ=0"));
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ТабличныйДокумент

// Возвращает признак соответствия текста ячейки формату экспоненциальной записи.
//  Это позволяет принять решение, рассчитывать ли данное значение методом ПривестиЗначение
//  или отказаться от расчета, поскольку приведение к числу может потребовать значительных
//  вычислительных ресурсов процессора.
//
// Параметры:
//  ТекстЯчейки - Строка - значение выделенной ячейки.
//
// Возвращаемое значение: 
//   Булево - если Истина, то текст имеет вид экспоненциальной записи.
//
Функция ТекстЯчейкиВидаЭкспоненциальнойЗаписи(Знач ТекстЯчейки)
	
	ЧислоВхождений = 0;
	ТекстЯчейки = СтрЗаменить(ВРег(ТекстЯчейки), Символы.НПП, "");
	
	// Замена символов разделителей дробной части.
	ТекстЯчейки = СтрЗаменить(ТекстЯчейки, Символ(44), ""); // Запятая ','
	ТекстЯчейки = СтрЗаменить(ТекстЯчейки, Символ(46), ""); // Точка '.'
	
	КодыСимволовЭкспоненты = Новый Массив;
	КодыСимволовЭкспоненты.Добавить(1045); // Кириллическая 'E'
	КодыСимволовЭкспоненты.Добавить(69);   // Латинская 'E'
	
	Для Каждого Код Из КодыСимволовЭкспоненты Цикл 
		
		СимволЭкспоненты = Символ(Код);
		ЧислоВхождений = ЧислоВхождений + СтрЧислоВхождений(ТекстЯчейки, СимволЭкспоненты);
		ТекстЯчейки = СтрЗаменить(ТекстЯчейки, СимволЭкспоненты, "");
		
	КонецЦикла;
	
	Возврат ЧислоВхождений = 1 И СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(ТекстЯчейки);
	
КонецФункции

#КонецОбласти

#КонецОбласти
