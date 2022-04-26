﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Процедура ЗаписатьУзел(Узел, УзелПередЗаписью) Экспорт
	
	УзелОбъект = Узел.ПолучитьОбъект();
	
	Для Каждого КлючИЗначение Из УзелПередЗаписью Цикл
		
		Ключ = КлючИЗначение.Ключ;
		Значение = КлючИЗначение.Значение;
		
		Если ТипЗнч(Значение) = Тип("ТаблицаЗначений") Тогда
			УзелОбъект[Ключ].Загрузить(Значение);
		Иначе
			УзелОбъект[Ключ] = Значение;	
		КонецЕсли;
		
	КонецЦикла;
	
	НачатьТранзакцию();
	
	Попытка
			
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить(ОбщегоНазначения.ИмяТаблицыПоСсылке(Узел));
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Узел);
		Блокировка.Заблокировать();

		УзелОбъект.ДополнительныеСвойства.Вставить("ОтложеннаяЗаписьУзла");
		УзелОбъект.Записать();
		
		Отказ  = Ложь;
		ОбменДаннымиСервер.ФормаУзлаПриЗаписиНаСервере(УзелОбъект, Отказ);

		ЗафиксироватьТранзакцию();

	Исключение
	
		ОтменитьТранзакцию();
	    ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры


#КонецОбласти

#КонецЕсли