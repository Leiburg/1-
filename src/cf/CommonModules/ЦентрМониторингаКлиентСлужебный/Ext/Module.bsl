﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// См. ОбщегоНазначенияКлиентПереопределяемый.ПередПериодическойОтправкойДанныхКлиентаНаСервер
Процедура ПередПериодическойОтправкойДанныхКлиентаНаСервер(Параметры) Экспорт
	
	ТекущаяДатаСеанса = ОбщегоНазначенияКлиент.ДатаСеанса();
	ИмяПараметра = "СтандартныеПодсистемы.ЦентрМониторинга.ДатаПоследнегоВызова";
	ДатаПоследнегоВызова = ПараметрыПриложения.Получить(ИмяПараметра);
	Если ТипЗнч(ДатаПоследнегоВызова) <> Тип("Дата") Тогда
		ПараметрыПриложения.Вставить(ИмяПараметра, ТекущаяДатаСеанса);
		Возврат;
	ИначеЕсли ДатаПоследнегоВызова + 20*60 > ТекущаяДатаСеанса Тогда
		Возврат;
	КонецЕсли;
	ПараметрыПриложения.Вставить(ИмяПараметра, ТекущаяДатаСеанса);
	
	Окна = ПолучитьОкна();
	АктивныхОкон = 0;
	Если Окна <> Неопределено Тогда
		Для Каждого ТекОкно Из Окна Цикл
			Если Не ТекОкно.Основное Тогда
				АктивныхОкон = АктивныхОкон + 1;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ПараметрыПриложенияЦентрМониторинга = ПолучитьПараметрыПриложения();
	ПараметрыПриложенияЦентрМониторинга["ИнформацияКлиента"].Вставить("АктивныхОкон", АктивныхОкон);
	
	Параметры.Вставить("СтандартныеПодсистемы.ЦентрМониторинга",
		Новый ФиксированноеСоответствие(ПараметрыПриложенияЦентрМониторинга));
	
	Замеры = Новый Соответствие;
	Замеры.Вставить(0, Новый Массив);
	Замеры.Вставить(1, Новый Соответствие);
	Замеры.Вставить(2, Новый Соответствие);
	ПараметрыПриложенияЦентрМониторинга.Вставить("Замеры", Замеры);
	
КонецПроцедуры

// См. ОбщегоНазначенияКлиентПереопределяемый.ПослеПериодическогоПолученияДанныхКлиентаНаСервере
Процедура ПослеПериодическогоПолученияДанныхКлиентаНаСервере(Результаты) Экспорт
	
	Результат = Результаты.Получить("СтандартныеПодсистемы.ЦентрМониторинга");
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыПриложенияЦентрМониторинга = ПолучитьПараметрыПриложения();
	ПараметрыПриложенияЦентрМониторинга.Вставить("РегистрироватьБизнесСтатистику",
		Результат["РегистрироватьБизнесСтатистику"]);
	
	Если Результат.Получить("ЗапросНаПолучениеДампов") = Истина Тогда
		ОповеститьЗапросНаПолучениеДампов();
		УстановитьПараметрыПриложенияЦентрМониторинга("ЗапросПолныхДамповВыведен", Истина);
	КонецЕсли;
	Если Результат.Получить("ЗапросНаПолучениеКонтактов") = Истина Тогда
		ОповеститьЗапросКонтактнойИнформации();
		УстановитьПараметрыПриложенияЦентрМониторинга("ЗапросНаПолучениеКонтактовВыведен", Истина);
	КонецЕсли;
	Если Результат.Получить("ЗапросНаОтправкуДампов") = Истина Тогда
		ИнформацияОДампах = Результат.Получить("ИнформацияОДампах");
		// Проверяем, было ли сообщение выведено ранее.
		Если ИнформацияОДампах <> ПараметрыПриложенияЦентрМониторинга["ИнформацияОДампах"] Тогда
			ОповеститьЗапросНаОтправкуДампов();
			УстановитьПараметрыПриложенияЦентрМониторинга("ИнформацияОДампах", ИнформацияОДампах);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// См. описание этой же процедуры в общем модуле
// ОбщегоНазначенияКлиентПереопределяемый.
//
Процедура ПриНачалеРаботыСистемы(Параметры) Экспорт
    
    ЦентрМониторингаПараметрыПриложения = ПолучитьПараметрыПриложения();
	
	Если Не ЦентрМониторингаПараметрыПриложения["ИнформацияКлиента"]["ПараметрыКлиента"]["ВыводитьЗапросПолныхДампов"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	Если ЦентрМониторингаПараметрыПриложения["ИнформацияКлиента"]["ПараметрыКлиента"]["ЗапросНаПолучениеДампов"] = Истина Тогда
		ПодключитьОбработчикОжидания("ЦентрМониторингаЗапросНаСборИОтправкуДампов",90, Истина);
		УстановитьПараметрыПриложенияЦентрМониторинга("ЗапросПолныхДамповВыведен", Истина);
	КонецЕсли;
	Если ЦентрМониторингаПараметрыПриложения["ИнформацияКлиента"]["ПараметрыКлиента"]["ЗапросНаОтправку"] = Истина Тогда
		ПодключитьОбработчикОжидания("ЦентрМониторингаЗапросНаОтправкуДампов",90, Истина);
		ИнформацияОДампах = ЦентрМониторингаПараметрыПриложения["ИнформацияКлиента"]["ПараметрыКлиента"]["ИнформацияОДампах"];
		УстановитьПараметрыПриложенияЦентрМониторинга("ИнформацияОДампах", ИнформацияОДампах);
	КонецЕсли;
	Если ЦентрМониторингаПараметрыПриложения["ИнформацияКлиента"]["ПараметрыКлиента"]["ЗапросНаПолучениеКонтактов"] = Истина Тогда
		ПодключитьОбработчикОжидания("ЦентрМониторингаЗапросКонтактнойИнформации",120, Истина);
		УстановитьПараметрыПриложенияЦентрМониторинга("ЗапросНаПолучениеКонтактовВыведен", Истина);
	КонецЕсли;
	   
КонецПроцедуры

Функция ПолучитьПараметрыПриложения() Экспорт
    
    Если ПараметрыПриложения = Неопределено Тогда
    	ПараметрыПриложения = Новый Соответствие;
    КонецЕсли;
    
    ИмяПараметра = "СтандартныеПодсистемы.ЦентрМониторинга";
    Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
        
        ПараметрыКлиента = ПараметрыКлиента();
        
        ПараметрыПриложения.Вставить(ИмяПараметра, Новый Соответствие);
        ЦентрМониторингаПараметрыПриложения = ПараметрыПриложения[ИмяПараметра];
        ЦентрМониторингаПараметрыПриложения.Вставить("РегистрироватьБизнесСтатистику", ПараметрыКлиента["РегистрироватьБизнесСтатистику"]);
		ЦентрМониторингаПараметрыПриложения.Вставить("ЗапросПолныхДамповВыведен", ПараметрыКлиента["ЗапросПолныхДамповВыведен"]);
		ЦентрМониторингаПараметрыПриложения.Вставить("ИнформацияОДампах", ПараметрыКлиента["ИнформацияОДампах"]);		
		
        Замеры = Новый Соответствие;
        Замеры.Вставить(0, Новый Массив);
        Замеры.Вставить(1, Новый Соответствие);
        Замеры.Вставить(2, Новый Соответствие);
        ЦентрМониторингаПараметрыПриложения.Вставить("Замеры", Замеры);
        
        ЦентрМониторингаПараметрыПриложения.Вставить("ИнформацияКлиента", ПолучитьИнформациюКлиента());
        
    Иначе
        
        ЦентрМониторингаПараметрыПриложения = ПараметрыПриложения["СтандартныеПодсистемы.ЦентрМониторинга"];
                       
    КонецЕсли;
    
    Возврат ЦентрМониторингаПараметрыПриложения; 
    
КонецФункции

Функция ПолучитьИнформациюКлиента()
    
    ИнформацияКлиента = Новый Соответствие;
    
    ИнформацияЭкраны = Новый Массив;
    ЭкраныКлиента = ПолучитьИнформациюЭкрановКлиента();
    Для Каждого ТекЭкран Из ЭкраныКлиента Цикл
        ИнформацияЭкраны.Добавить(РазрешениеЭкранаВСтроку(ТекЭкран));
    КонецЦикла;
    
    ИнформацияКлиента.Вставить("ЭкраныКлиента", ИнформацияЭкраны);
    ИнформацияКлиента.Вставить("ПараметрыКлиента", ПараметрыКлиента());
    ИнформацияКлиента.Вставить("ИнформацияОСистеме", ПолучитьИнформациюОСистеме());
    ИнформацияКлиента.Вставить("АктивныхОкон", 0);
    
    Возврат ИнформацияКлиента;
    
КонецФункции

Функция РазрешениеЭкранаВСтроку(Экран)
    
    Возврат Формат(Экран.Ширина, "ЧГ=0") + "x" + Формат(Экран.Высота, "ЧГ=0");
    
КонецФункции

Функция ПараметрыКлиента()
    
    ПараметрыКлиента = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске(),"ЦентрМониторинга");
    Если ПараметрыКлиента = Неопределено Тогда
        ПараметрыКлиента = Новый Структура;
		ПараметрыКлиента.Вставить("ЧасовойПоясСеанса", Неопределено);
		ПараметрыКлиента.Вставить("ХешПользователя", Неопределено);
		ПараметрыКлиента.Вставить("РегистрироватьБизнесСтатистику", Ложь);
		ПараметрыКлиента.Вставить("ВыводитьЗапросПолныхДампов", Ложь);
		ПараметрыКлиента.Вставить("ЗапросПолныхДамповВыведен", Ложь);
		ПараметрыКлиента.Вставить("ИнформацияОДампах", "");
		ПараметрыКлиента.Вставить("ЗапросНаПолучениеДампов", Ложь);
		ПараметрыКлиента.Вставить("ЗапросНаОтправку", Ложь);
		ПараметрыКлиента.Вставить("ЗапросНаПолучениеКонтактов", Ложь);
		ПараметрыКлиента.Вставить("ЗапросНаПолучениеКонтактовВыведен", Ложь);
    КонецЕсли;
    
    ПараметрыКлиентаИнформация = Новый Соответствие;
    Для Каждого ТекПараметр Из ПараметрыКлиента Цикл
        ПараметрыКлиентаИнформация.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
    КонецЦикла;
        
    Возврат ПараметрыКлиентаИнформация; 
        
КонецФункции

Функция ПолучитьИнформациюОСистеме()
    
    СисИнфо = Новый СистемнаяИнформация();
    
    СисИнфоИнформация = Новый Соответствие;
    СисИнфоИнформация.Вставить("ВерсияОС", СтрЗаменить(СисИнфо.ВерсияОС, ".", "☺"));
    СисИнфоИнформация.Вставить("ОперативнаяПамять", Формат((ЦЕЛ(СисИнфо.ОперативнаяПамять/512) + 1) * 512, "ЧГ=0"));
    СисИнфоИнформация.Вставить("Процессор", СтрЗаменить(СисИнфо.Процессор, ".", "☺"));
    СисИнфоИнформация.Вставить("ТипПлатформы", СтрЗаменить(Строка(СисИнфо.ТипПлатформы), ".", "☺"));
        
    ИнформацияПрограммыПросмотра = "";
    #Если ТолстыйКлиентУправляемоеПриложение Тогда
        ИнформацияПрограммыПросмотра = "ТолстыйКлиентУправляемоеПриложение";
    #ИначеЕсли ТолстыйКлиентОбычноеПриложение Тогда
        ИнформацияПрограммыПросмотра = "ТолстыйКлиент";
    #ИначеЕсли ТонкийКлиент Тогда
        ИнформацияПрограммыПросмотра = "ТонкийКлиент";
    #ИначеЕсли ВебКлиент Тогда                                                          
        ИнформацияПрограммыПросмотра = "ВебКлиент";
    #КонецЕсли
    
    СисИнфоИнформация.Вставить("ИнформацияПрограммыПросмотра", ИнформацияПрограммыПросмотра);
    
    Возврат СисИнфоИнформация; 
    
КонецФункции

Процедура УстановитьПараметрыПриложенияЦентрМониторинга(Параметр, Значение)
	ИмяПараметра = "СтандартныеПодсистемы.ЦентрМониторинга";
	Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
		Возврат;
	Иначе
		ЦентрМониторингаПараметрыПриложения = ПараметрыПриложения["СтандартныеПодсистемы.ЦентрМониторинга"];
		ЦентрМониторингаПараметрыПриложения.Вставить(Параметр, Значение);
	КонецЕсли;
КонецПроцедуры

Процедура ОповеститьЗапросНаПолучениеДампов() Экспорт
	ПоказатьОповещениеПользователя(НСтр("ru = 'Отчеты об ошибках'"),
			"e1cib/app/Обработка.НастройкиЦентраМониторинга.Форма.ЗапросНаСборИОтправкуОтчетовОбОшибках",
			НСтр("ru = 'Предоставьте отчеты о возникающих ошибках'"),
			БиблиотекаКартинок.Предупреждение32,
			СтатусОповещенияПользователя.Важное, "ЗапросНаПолучениеДампов");		
КонецПроцедуры

Процедура ОповеститьЗапросНаОтправкуДампов() Экспорт
	ПоказатьОповещениеПользователя(НСтр("ru = 'Отчеты об ошибках'"),
				"e1cib/app/Обработка.НастройкиЦентраМониторинга.Форма.ЗапросНаОтправкуОтчетовОбОшибках",
				НСтр("ru = 'Отправьте отчеты о возникающих ошибках'"),
				БиблиотекаКартинок.Предупреждение32,
				СтатусОповещенияПользователя.Важное, "ЗапросНаОтправкуДампов");
КонецПроцедуры

Процедура ОповеститьЗапросКонтактнойИнформации() Экспорт
	ПоказатьОповещениеПользователя(НСтр("ru = 'Проблемы производительности'"),
				Новый ОписаниеОповещения(
						"ПриНажатииОповещенияЗапросКонтактнойИнформации",
						ЭтотОбъект, Истина),
				НСтр("ru = 'Сообщить о проблемах производительности'"),
				БиблиотекаКартинок.Предупреждение32,
				СтатусОповещенияПользователя.Важное, "ЗапросКонтактнойИнформации");
КонецПроцедуры
			
Процедура ПриНажатииОповещенияЗапросКонтактнойИнформации(ПоЗапросу) Экспорт
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПоЗапросу", ПоЗапросу);
	ОткрытьФорму("Обработка.НастройкиЦентраМониторинга.Форма.ОтправкаКонтактнойИнформации", ПараметрыФормы);
	
КонецПроцедуры			
			

#КонецОбласти